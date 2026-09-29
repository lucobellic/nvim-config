<div align="center">

# Neovim Configuration

![neovim](https://img.shields.io/static/v1?&label&logoColor=white&color=green&message=0.13&logo=neovim&style=for-the-badge)
![lua](https://img.shields.io/static/v1?&label&color=blue&message=Lua&logo=lua&style=for-the-badge)
![gitmoji](https://img.shields.io/static/v1?&label&color=ffdd67&message=😜😍%20gitmoji&style=for-the-badge&link=https://gitmoji.dev)

</div>

<div align="center">
A clean and aesthetic Neovim configuration made for my personal use
</div>

<br>

<table>
  <tr>
    <td><img src="doc/images/nvim-config-start.png" alt="Neovim start screen"></td>
    <td><img src="doc/images/nvim-config.png" alt="Neovim configuration"></td>
  </tr>
</table>

<p align="center">
  <a href="https://github.com/lucobellic/ayugloom.nvim">ayugloom.nvim</a>, based on the ayu theme with personal preferences.<br>
  <a href="https://fonts.google.com/specimen/DM+Mono">DM Mono</a> Nerd Font with added ligatures.
</p>

<div align="center">
  <h2>Animated logo</h2>
</div>

The dashboard logo starts with [`local/logo/logo.txt`](local/logo/logo.txt).  
From the repository root, generate its 360 color frames with Rust:

```sh
cargo run -qr -m local/logo/Cargo.toml -- \
  local/logo/logo.txt --palette vivid --generate local/logo/rainbow-logo.cache
```

The [dashboard](lua/plugins/snacks/snacks-dashboard.lua) plays the cache with `local/logo/rainbow-logo.sh --speed 10`.  
Edit the text file and rerun the command to change the logo.
