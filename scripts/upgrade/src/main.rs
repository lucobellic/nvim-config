use std::fmt;
use std::path::PathBuf;

use inquire::{Select, error::InquireResult};

struct ReleaseDisplay<'a> {
    release: &'a octocrab::models::repos::Release,
}

impl fmt::Display for ReleaseDisplay<'_> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.release.tag_name)
    }
}

/// Fetches the list of available releases from the Neovim GitHub repository.
///
/// # Errors
///
/// Returns an error if the GitHub API request fails or the response cannot be parsed.
async fn get_available_releases() -> Result<Vec<octocrab::models::repos::Release>, octocrab::Error>
{
    Ok(octocrab::instance()
        .repos("neovim", "neovim")
        .releases()
        .list()
        .send()
        .await?
        .items)
}

/// Prompts the user to select a release version from the list of available releases.
///
/// Displays the available `releases` as an interactive selection menu and returns
/// the user's choice.
///
/// # Errors
///
/// Returns an error if the user aborts the selection or terminal interaction fails.
fn select_version(
    releases: &[octocrab::models::repos::Release],
) -> InquireResult<&octocrab::models::repos::Release> {
    let choices: Vec<_> = releases
        .iter()
        .map(|r| ReleaseDisplay { release: r })
        .collect();
    let selection = Select::new("Choose version:", choices).prompt()?;
    Ok(selection.release)
}

/// Downloads the specified `release` and returns the path to the downloaded file.
///
/// # Errors
///
/// Returns an error if the download fails or the file cannot be written.
async fn download_release(
    release: &octocrab::models::repos::Release,
) -> Result<PathBuf, Box<dyn std::error::Error>> {
    let asset = release
        .assets
        .iter()
        .find(|a| a.name.contains("nvim-linux-x86_64.tar.gz"))
        .ok_or("no matching asset found")?;

    let dir = std::env::temp_dir().join(format!("nvim-upgrade-{}", release.tag_name));
    tokio::fs::create_dir_all(&dir).await?;

    let filename = asset.name.split('/').next_back().unwrap_or(&asset.name);
    let dest = dir.join(filename);

    let response = reqwest::get(asset.browser_download_url.as_str()).await?;
    let bytes = response.bytes().await?;
    tokio::fs::write(&dest, &bytes).await?;

    println!("Downloaded to {}", dest.display());
    Ok(dest)
}

/// Installs the downloaded release from the specified `path` into the user's local directory.
///
/// # Errors
///
/// Returns an error if the installation fails or the destination directory cannot be created.
fn install(path: &PathBuf) -> Result<(), Box<dyn std::error::Error>> {
    let home = std::env::var("HOME").map_err(|_| "$HOME not set")?;
    let local = PathBuf::from(home).join(".local");

    let file = std::fs::File::open(path)?;
    let decoder = flate2::read::GzDecoder::new(file);
    let mut archive = tar::Archive::new(decoder);

    for entry in archive.entries()? {
        let mut entry = entry?;
        let entry_path = entry.path()?;
        let stripped: PathBuf = entry_path.components().skip(1).collect();
        let dest = local.join(&stripped);

        if let Some(parent) = dest.parent() {
            std::fs::create_dir_all(parent)?;
        }
        entry.unpack(&dest)?;
    }

    println!("Installed to {}", local.display());
    Ok(())
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let releases = get_available_releases().await?;
    let release = select_version(&releases)?;
    let path = download_release(release).await?;
    install(&path)?;
    Ok(())
}
