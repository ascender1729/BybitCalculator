require 'tk'

root = TkRoot.new { title "Icon Test" }
icon_path = File.expand_path('../assets/cal.ico', __FILE__)
root.wm_iconbitmap(icon_path)
Tk.mainloop