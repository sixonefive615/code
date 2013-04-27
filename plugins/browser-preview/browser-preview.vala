// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/***
  BEGIN LICENSE
	
  Copyright (C) 2011-2012 Mario Guerriero <mefrio.g@gmail.com>
  This program is free software: you can redistribute it and/or modify it	
  under the terms of the GNU Lesser General Public License version 3, as published	
  by the Free Software Foundation.
	
  This program is distributed in the hope that it will be useful, but	
  WITHOUT ANY WARRANTY; without even the implied warranties of	
  MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR	
  PURPOSE.  See the GNU General Public License for more details.
	
  You should have received a copy of the GNU General Public License along	
  with this program.  If not, see <http://www.gnu.org/licenses/>	
  
  END LICENSE	
***/

using WebKit;

public class Scratch.Plugins.BrowserPreview : Peas.ExtensionBase,  Peas.Activatable {
    
    Gtk.Notebook? context = null;   
    Gtk.ToolButton? tool_button = null;
    WebView? view = null;
    Gtk.ScrolledWindow? scrolled = null;
    
    Scratch.Services.Interface plugins;
    public Object object { owned get; construct; }
   
    public void update_state () {
    }

    public void activate () {
        plugins = (Scratch.Services.Interface) object;        
        plugins.hook_notebook_context.connect ((n) => { 
            if (context == null) {
                this.context = n;
                on_hook_context (this.context);
            }
        });
        if (context != null)
            on_hook_context (this.context);
            
        plugins.hook_toolbar.connect (on_hook_toolbar);
    }
    
    public void deactivate () {
        if (tool_button != null)
            tool_button.destroy ();
        
        if (scrolled != null)
            scrolled.destroy ();
    }
    
    void on_hook_toolbar (Gtk.Toolbar toolbar) {
        Scratch.Services.Document? doc = null;
        plugins.hook_document.connect ((d) => {
            doc = d;
        });
        
        var icon = new Gtk.Image.from_icon_name ("emblem-web", Gtk.IconSize.LARGE_TOOLBAR);
        tool_button = new Gtk.ToolButton (icon, _("Get preview!"));
        tool_button.tooltip_text = _("Get preview!");
        tool_button.clicked.connect (() => {              
            // Get uri
            if (doc.file == null)
                return;
            string uri = doc.file.get_uri ();
                
            debug ("Previewing: " + doc.file.get_basename ());
                
            view.load_uri (uri);
        });
            
        icon.show ();
        tool_button.show ();
            
        toolbar.insert (tool_button, 7);
    }
    
    void on_hook_context (Gtk.Notebook notebook) {
    	view = new WebView ();
    	// Enable local loading
    	var settings = view.get_settings ();
    	settings.enable_file_access_from_file_uris = true;
    	    
    	scrolled = new Gtk.ScrolledWindow (null, null);
    	scrolled.add (view);
    	    
    	notebook.append_page (scrolled, new Gtk.Label (_("Web preview")));
    	
    	scrolled.show_all ();
    }

}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                     typeof (Scratch.Plugins.BrowserPreview));
}
