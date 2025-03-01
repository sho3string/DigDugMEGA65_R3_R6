----------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- Wrapper for the MiSTer core that runs exclusively in the core's clock domanin
--
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2022 and licensed under GPL v3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.video_modes_pkg.all;

entity main is
   generic (
      G_VDNUM                 : natural                     -- amount of virtual drives
   );
   port (
      clk_main_i              : in  std_logic;
      reset_soft_i            : in  std_logic;
      reset_hard_i            : in  std_logic;
      pause_i                 : in  std_logic;
      dim_video_o             : out std_logic;
      
      rom_download            : in  std_logic;

      -- MiSTer core main clock speed:
      -- Make sure you pass very exact numbers here, because they are used for avoiding clock drift at derived clocks
      clk_main_speed_i        : in  natural;

      -- Video output
      video_clk_o             : out std_logic;
      video_ce_o              : out std_logic;
      video_ce_ovl_o          : out std_logic;
      video_red_o             : out std_logic_vector(3 downto 0);
      video_green_o           : out std_logic_vector(3 downto 0);
      video_blue_o            : out std_logic_vector(3 downto 0);
      video_vs_o              : out std_logic;
      video_hs_o              : out std_logic;
      video_hblank_o          : out std_logic;
      video_vblank_o          : out std_logic;

      -- Audio output (Signed PCM)
      audio_left_o            : out signed(15 downto 0);
      audio_right_o           : out signed(15 downto 0);

      -- M2M Keyboard interface
      kb_key_num_i            : in  integer range 0 to 79;    -- cycles through all MEGA65 keys
      kb_key_pressed_n_i      : in  std_logic;                -- low active: debounced feedback: is kb_key_num_i pressed right now?

      -- MEGA65 joysticks and paddles/mouse/potentiometers
      joy_1_up_n_i            : in  std_logic;
      joy_1_down_n_i          : in  std_logic;
      joy_1_left_n_i          : in  std_logic;
      joy_1_right_n_i         : in  std_logic;
      joy_1_fire_n_i          : in  std_logic;

      joy_2_up_n_i            : in  std_logic;
      joy_2_down_n_i          : in  std_logic;
      joy_2_left_n_i          : in  std_logic;
      joy_2_right_n_i         : in  std_logic;
      joy_2_fire_n_i          : in  std_logic;

      pot1_x_i                : in  std_logic_vector(7 downto 0);
      pot1_y_i                : in  std_logic_vector(7 downto 0);
      pot2_x_i                : in  std_logic_vector(7 downto 0);
      pot2_y_i                : in  std_logic_vector(7 downto 0);
      
       -- Dipswitches
      dsw_a_i                 : in  std_logic_vector(7 downto 0);
      dsw_b_i                 : in  std_logic_vector(7 downto 0);

      -- Rom loading
      dn_clk_i                : in  std_logic;
      dn_addr_i               : in  std_logic_vector(15 downto 0);
      dn_data_i               : in  std_logic_vector(7 downto 0);
      dn_wr_i                 : in  std_logic;
      
      osm_control_i      : in  std_logic_vector(255 downto 0)
   );
end entity main;

architecture synthesis of main is

signal keyboard_n        : std_logic_vector(79 downto 0);
signal pause_cpu         : std_logic;
signal direct_video      : std_logic;
signal forced_scandoubler: std_logic;
--signal no_rotate         : std_logic := status(2) OR direct_video;
signal gamma_bus         : std_logic_vector(21 downto 0);
signal audio             : std_logic_vector(15 downto 0);

-- I/O board button press simulation ( active high )
-- b[1]: user button
-- b[0]: osd button

signal buttons           : std_logic_vector(1 downto 0);
signal reset             : std_logic  := reset_hard_i or reset_soft_i;

-- highscore system
signal hs_address       : std_logic_vector(15 downto 0);
signal hs_data_in       : std_logic_vector(7 downto 0);
signal hs_data_out      : std_logic_vector(7 downto 0);
signal hs_write_enable  : std_logic;
signal hs_access_read   : std_logic;
signal hs_access_write  : std_logic;

signal hs_pause         : std_logic;
signal options          : std_logic_vector(1 downto 0);
signal self_test        : std_logic;


signal oSND             : std_logic_vector(7 downto 0);
signal POUT             : std_logic_vector(11  downto 0);
signal oPix             : std_logic_vector(7  downto 0);
signal oRGB             : std_logic_vector(11 downto 0);
signal HPOS,VPOS        : std_logic_vector(8 downto 0);

constant C_MENU_OSMPAUSE     : natural := 2;
constant C_MENU_OSMDIM       : natural := 3;
constant C_MENU_FLIP_SCR     : natural := 9;

-- Game player inputs
constant m65_1             : integer := 56; --Player 1 Start
constant m65_2             : integer := 59; --Player 2 Start
constant m65_5             : integer := 16; --Insert coin 1
constant m65_6             : integer := 19; --Insert coin 2

-- Offer some keyboard controls in addition to Joy 1 Controls
constant m65_up_crsr       : integer := 73; -- Player up 1
constant m65_vert_crsr     : integer := 7;  -- Player down 1
constant m65_left_crsr     : integer := 74; -- Player left 1
constant m65_horz_crsr     : integer := 2;  -- Player right 1
constant m65_space         : integer := 60; -- Trigger 1
constant m65_left_shift    : integer := 15; -- Trigger 2 

constant m65_i             : integer := 33; -- Player up 2
constant m65_j             : integer := 34; -- Player left 2
constant m65_k             : integer := 37; -- Player right 2
constant m65_l             : integer := 42; -- Plpayer down 2

-- Pause, credit button & test mode
constant m65_p             : integer := 41; -- Pause button
constant m65_s             : integer := 13; -- Service 1
constant m65_capslock      : integer := 72; -- Service Mode
constant m65_help          : integer := 67; -- Help key

begin

    audio_left_o(15) <= not audio(15);
    audio_left_o(14 downto 0) <= signed(audio(14 downto 0));
    audio_right_o(15) <= not audio(15);
    audio_right_o(14 downto 0) <= signed(audio(14 downto 0));
    
    options(0) <= osm_control_i(C_MENU_OSMPAUSE);
    options(1) <= osm_control_i(C_MENU_OSMDIM);
    
    oRGB    <= video_blue_o & video_green_o & video_red_o;
    POUT    <= oPIX(7 downto 6) & "00" & oPIX(5 downto 3) & '0' & oPIX(2 downto 0) & '0';
    audio   <= oSND & "00000000";
    
    i_hvgen : entity work.hvgen
      port map (
         
         PCLK       => video_ce_o,
         iRGB       => POUT,
         oRGB       => oRGB,
         HBLK       => video_hblank_o,
         VBLK       => video_vblank_o,
         HSYN       => video_hs_o,
         VSYN       => video_vs_o,
         HPOS       => HPOS,
         VPOS       => VPOS
     );
     
    i_digdug : entity work.fpga_digdug
    port map (
    
        RESET      => reset,
        MCLK       => clk_main_i,
        
        INP0(7)    => not keyboard_n(m65_s),                                -- service button
        INP0(6)    => '0',                                                  -- ??
        INP0(5)    => not keyboard_n(m65_6),                                -- coin 2
        INP0(4)    => not keyboard_n(m65_5),                                -- coin 1
        INP0(3)    => not keyboard_n(m65_2),                                -- start 2
        INP0(2)    => not keyboard_n(m65_1),                                -- start 1                 
        INP0(1)    => not joy_2_fire_n_i or not keyboard_n(m65_space),      -- Trigger 2
        INP0(0)    => not joy_1_fire_n_i or not keyboard_n(m65_space),      -- Trigger 1
        INP1(7)    => not joy_2_left_n_i or not keyboard_n(m65_left_crsr),
        INP1(6)    => not joy_2_down_n_i or not keyboard_n(m65_vert_crsr),
        INP1(5)    => not joy_2_right_n_i or not keyboard_n(m65_horz_crsr),
        INP1(4)    => not joy_2_up_n_i or not keyboard_n(m65_up_crsr),
        INP1(3)    => not joy_1_left_n_i or not keyboard_n(m65_left_crsr), 
        INP1(2)    => not joy_1_down_n_i or not keyboard_n(m65_vert_crsr),
        INP1(1)    => not joy_1_right_n_i or not keyboard_n(m65_horz_crsr),
        INP1(0)    => not joy_1_up_n_i or not keyboard_n(m65_up_crsr),
        
        DSW0       => not dsw_a_i,
        DSW1       => not dsw_b_i,
        
        PH         => HPOS,
        PV         => VPOS,
        PCLK       => video_ce_o,
        POUT       => oPIX,
        SOUT       => oSND,
        
        ROMCL      => dn_clk_i,
        ROMAD      => dn_addr_i,
        ROMDT      => dn_data_i,
        ROMEN      => dn_wr_i and rom_download,
        
        V_FLIP     => osm_control_i(C_MENU_FLIP_SCR),
       
        pause      => pause_cpu or pause_i,
        
        hs_address => hs_address,
        hs_data_out=> hs_data_out,
        hs_data_in => hs_data_in,
        hs_write   => hs_write_enable,
        hs_access  => hs_access_read or hs_access_write
  
 );
 
 i_pause : entity work.pause
     generic map (
     
        RW  => 4,
        GW  => 4,
        BW  => 4,
        CLKSPD => 24
        
     )         
     port map (
         clk_sys        => clk_main_i,
         reset          => reset,
         user_button    => keyboard_n(m65_p),
         pause_request  => hs_pause,
         options        => options,   -- not status(11 downto 10), - TODO, hookup to OSD.
         OSD_STATUS     => '0',       -- disabled for now - TODO, to OSD
         r              => video_red_o,
         g              => video_green_o,
         b              => video_blue_o,
         pause_cpu      => pause_cpu,
         dim_video      => dim_video_o
         --rgb_out        TODO
         
      );
  

   i_keyboard : entity work.keyboard
      port map (
         clk_main_i           => clk_main_i,

         -- Interface to the MEGA65 keyboard
         key_num_i            => kb_key_num_i,
         key_pressed_n_i      => kb_key_pressed_n_i,

         -- @TODO: Create the kind of keyboard output that your core needs
         -- "example_n_o" is a low active register and used by the demo core:
         --    bit 0: Space
         --    bit 1: Return
         --    bit 2: Run/Stop
         example_n_o          => keyboard_n
      ); -- i_keyboard

end architecture synthesis;

