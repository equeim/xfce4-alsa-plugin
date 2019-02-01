/* libxfce4panel-2.0.vapi generated by vapigen-0.42, do not modify. */

[CCode (cprefix = "Xfce", gir_namespace = "libxfce4panel", gir_version = "2.0", lower_case_cprefix = "xfce_")]
namespace Xfce {
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", type_id = "xfce_arrow_button_get_type ()")]
	public class ArrowButton : Gtk.ToggleButton, Atk.Implementor, Gtk.Actionable, Gtk.Activatable, Gtk.Buildable {
		[CCode (has_construct_function = false, type = "GtkWidget*")]
		public ArrowButton (Gtk.ArrowType arrow_type);
		public Gtk.ArrowType get_arrow_type ();
		[Version (since = "4.8")]
		public bool get_blinking ();
		public void set_arrow_type (Gtk.ArrowType arrow_type);
		[Version (since = "4.8")]
		public void set_blinking (bool blinking);
		public Gtk.ArrowType arrow_type { get; set; }
		public virtual signal void arrow_type_changed (Gtk.ArrowType type);
	}
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", type_id = "xfce_panel_image_get_type ()")]
	public class PanelImage : Gtk.Widget, Atk.Implementor, Gtk.Buildable {
		[CCode (has_construct_function = false, type = "GtkWidget*")]
		[Version (since = "4.8")]
		public PanelImage ();
		[Version (since = "4.8")]
		public void clear ();
		[CCode (has_construct_function = false, type = "GtkWidget*")]
		[Version (since = "4.8")]
		public PanelImage.from_pixbuf (Gdk.Pixbuf? pixbuf);
		[CCode (has_construct_function = false, type = "GtkWidget*")]
		[Version (since = "4.8")]
		public PanelImage.from_source (string? source);
		[Version (since = "4.8")]
		public int get_size ();
		[Version (since = "4.8")]
		public void set_from_pixbuf (Gdk.Pixbuf? pixbuf);
		[Version (since = "4.8")]
		public void set_from_source (string? source);
		[Version (since = "4.8")]
		public void set_size (int size);
		[NoAccessorMethod]
		public Gdk.Pixbuf pixbuf { owned get; set; }
		public int size { get; set; }
		[NoAccessorMethod]
		public string source { owned get; set; }
	}
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", type_id = "xfce_panel_plugin_get_type ()")]
	public class PanelPlugin : Gtk.EventBox, Atk.Implementor, Gtk.Buildable, Xfce.PanelPluginProvider {
		[CCode (has_construct_function = false)]
		protected PanelPlugin ();
		public void add_action_widget (Gtk.Widget widget);
		public Gtk.ArrowType arrow_type ();
		public void block_autohide (bool blocked);
		public void block_menu ();
		[NoWrapper]
		public virtual void @construct ();
		public void focus_widget (Gtk.Widget widget);
		[CCode (array_length = false, array_null_terminated = true)]
		[Version (since = "4.8")]
		public unowned string[] get_arguments ();
		[Version (since = "4.8")]
		public unowned string get_comment ();
		public unowned string get_display_name ();
		public bool get_expand ();
		[Version (since = "4.14")]
		public int get_icon_size ();
		[Version (since = "4.8")]
		public bool get_locked ();
		[Version (since = "4.10")]
		public Xfce.PanelPluginMode get_mode ();
		[Version (since = "4.10")]
		public uint get_nrows ();
		public Gtk.Orientation get_orientation ();
		public unowned string get_property_base ();
		public Xfce.ScreenPosition get_screen_position ();
		[Version (since = "4.10")]
		public bool get_shrink ();
		public int get_size ();
		[Version (since = "4.10")]
		public bool get_small ();
		public string lookup_rc_file ();
		public void menu_insert_item (Gtk.MenuItem item);
		public void menu_show_about ();
		public void menu_show_configure ();
		public static void position_menu (Gtk.Menu menu, out int x, out int y, bool push_in, void* panel_plugin);
		public void position_widget (Gtk.Widget menu_widget, Gtk.Widget? attach_widget, out int x, out int y);
		public void register_menu (Gtk.Menu menu);
		[Version (since = "4.8")]
		public void remove ();
		public string save_location (bool create);
		public void set_expand (bool expand);
		public void set_shrink (bool shrink);
		public void set_small (bool small);
		[Version (since = "4.8")]
		public void take_window (Gtk.Window window);
		public void unblock_menu ();
		[CCode (array_length = false, array_null_terminated = true)]
		public string[] arguments { get; construct; }
		[Version (since = "4.8")]
		public string comment { get; construct; }
		public string display_name { get; construct; }
		public bool expand { get; set; }
		[Version (since = "4.14")]
		public int icon_size { get; }
		[Version (since = "4.10")]
		public Xfce.PanelPluginMode mode { get; }
		public string name { get; construct; }
		[Version (since = "4.10")]
		public uint nrows { get; }
		public Gtk.Orientation orientation { get; }
		public Xfce.ScreenPosition screen_position { get; }
		[Version (since = "4.10")]
		public bool shrink { get; set; }
		public int size { get; }
		[Version (since = "4.10")]
		public bool small { get; set; }
		public int unique_id { get; construct; }
		public virtual signal void about ();
		public virtual signal void configure_plugin ();
		public virtual signal void free_data ();
		[Version (since = "4.10")]
		public virtual signal void mode_changed (Xfce.PanelPluginMode mode);
		[Version (since = "4.10")]
		public virtual signal void nrows_changed (uint rows);
		public virtual signal void orientation_changed (Gtk.Orientation orientation);
		public virtual signal bool remote_event (string name, GLib.Value value);
		[Version (since = "4.8")]
		public virtual signal void removed ();
		public virtual signal void save ();
		public virtual signal void screen_position_changed (Xfce.ScreenPosition position);
		public virtual signal bool size_changed (int size);
	}
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", type_id = "g_type_module_get_type ()")]
	public class PanelTypeModule : GLib.TypeModule {
		[CCode (has_construct_function = false)]
		protected PanelTypeModule ();
	}
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", type_cname = "XfcePanelPluginProviderInterface", type_id = "xfce_panel_plugin_provider_get_type ()")]
	public interface PanelPluginProvider : GLib.Object {
		public abstract void ask_remove ();
		public void emit_signal (Xfce.PanelPluginProviderSignal provider_signal);
		public abstract unowned string get_name ();
		public abstract bool get_show_about ();
		public abstract bool get_show_configure ();
		public abstract int get_unique_id ();
		public abstract bool remote_event (string name, GLib.Value value, uint handle);
		public abstract void removed ();
		public abstract void save ();
		public abstract void set_icon_size (int icon_size);
		public abstract void set_locked (bool locked);
		public abstract void set_mode (Xfce.PanelPluginMode mode);
		public abstract void set_nrows (uint rows);
		public abstract void set_screen_position (Xfce.ScreenPosition screen_position);
		public abstract void set_size (int size);
		public abstract void show_about ();
		public abstract void show_configure ();
		public signal void provider_signal (uint object);
	}
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", cprefix = "XFCE_PANEL_PLUGIN_MODE_", type_id = "xfce_panel_plugin_mode_get_type ()")]
	[Version (since = "4.10")]
	public enum PanelPluginMode {
		HORIZONTAL,
		VERTICAL,
		DESKBAR
	}
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", cprefix = "PROVIDER_PROP_TYPE_", has_type_id = false)]
	public enum PanelPluginProviderPropType {
		SET_SIZE,
		SET_ICON_SIZE,
		SET_MODE,
		SET_SCREEN_POSITION,
		SET_BACKGROUND_ALPHA,
		SET_NROWS,
		SET_LOCKED,
		SET_SENSITIVE,
		SET_BACKGROUND_COLOR,
		SET_BACKGROUND_IMAGE,
		ACTION_REMOVED,
		ACTION_SAVE,
		ACTION_QUIT,
		ACTION_QUIT_FOR_RESTART,
		ACTION_BACKGROUND_UNSET,
		ACTION_SHOW_CONFIGURE,
		ACTION_SHOW_ABOUT,
		ACTION_ASK_REMOVE,
		SET_OPACITY
	}
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", cprefix = "PROVIDER_SIGNAL_", has_type_id = false)]
	public enum PanelPluginProviderSignal {
		MOVE_PLUGIN,
		EXPAND_PLUGIN,
		COLLAPSE_PLUGIN,
		SMALL_PLUGIN,
		UNSMALL_PLUGIN,
		LOCK_PANEL,
		UNLOCK_PANEL,
		REMOVE_PLUGIN,
		ADD_NEW_ITEMS,
		PANEL_PREFERENCES,
		PANEL_LOGOUT,
		PANEL_ABOUT,
		PANEL_HELP,
		SHOW_CONFIGURE,
		SHOW_ABOUT,
		FOCUS_PLUGIN,
		SHRINK_PLUGIN,
		UNSHRINK_PLUGIN
	}
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", cprefix = "XFCE_SCREEN_POSITION_", type_id = "xfce_screen_position_get_type ()")]
	public enum ScreenPosition {
		NONE,
		NW_H,
		N,
		NE_H,
		NW_V,
		W,
		SW_V,
		NE_V,
		E,
		SE_V,
		SW_H,
		S,
		SE_H,
		FLOATING_H,
		FLOATING_V
	}
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", cname = "PluginInitFunc", has_target = false)]
	public delegate GLib.Type InitFunc (GLib.TypeModule module, bool make_resident);
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", has_target = false)]
	public delegate bool PanelPluginCheck (Gdk.Screen screen);
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", has_target = false)]
	public delegate void PanelPluginFunc (Xfce.PanelPlugin plugin);
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", has_target = false)]
	[Version (since = "4.6")]
	public delegate bool PanelPluginPreInit (int argc, string argv);
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", cname = "LIBXFCE4PANEL_MAJOR_VERSION")]
	[Version (since = "4.8")]
	public const int MAJOR_VERSION;
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", cname = "LIBXFCE4PANEL_MICRO_VERSION")]
	[Version (since = "4.8")]
	public const int MICRO_VERSION;
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", cname = "LIBXFCE4PANEL_MINOR_VERSION")]
	[Version (since = "4.8")]
	public const int MINOR_VERSION;
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", cname = "LIBXFCE4PANEL_VERSION")]
	[Version (since = "4.8")]
	public const string VERSION;
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", cname = "xfce_allow_panel_customization")]
	[Version (deprecated = true, deprecated_since = "4.8")]
	public const bool allow_panel_customization;
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h", cname = "libxfce4panel_check_version")]
	[Version (since = "4.8")]
	public static unowned string check_version (uint required_major, uint required_minor, uint required_micro);
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h")]
	public static Gtk.Widget panel_create_button ();
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h")]
	public static Gtk.Widget panel_create_toggle_button ();
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h")]
	[Version (since = "4.8")]
	public static unowned string panel_get_channel_name ();
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h")]
	[Version (since = "4.8")]
	public static Gdk.Pixbuf panel_pixbuf_from_source (string source, Gtk.IconTheme? icon_theme, int size);
	[CCode (cheader_filename = "libxfce4panel/libxfce4panel.h")]
	[Version (since = "4.10")]
	public static Gdk.Pixbuf panel_pixbuf_from_source_at_size (string source, Gtk.IconTheme? icon_theme, int dest_width, int dest_height);
}