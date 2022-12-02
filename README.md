# Dotfiles
Configuration files for various programs to easily deploy my preferred configurations between machines

To deploy:
```bash
git clone https://github.com/JarredAllen/dotfiles.git dotfiles
cd dotfiles
./deploy.sh
```
Alternatively, you can specify a different directory to deploy to, as such:
```bash
./deploy.sh /path/to/home
```

## TODOs

* Installing plugins in Vim currently just waits 20 seconds (which I have found to be long enough
  in practice). I want to figure out how to figure out when it's done and close it then, so it
  becomes independent of connection speed and the number of plugins I run.
