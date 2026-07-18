use std::{
    fs,
    io::{self, IsTerminal, Read, Write},
    path::PathBuf,
    thread,
    time::Duration,
};

use clap::{Parser, ValueEnum};
use crossterm::{
    QueueableCommand,
    cursor::MoveTo,
    style::{Color, Print, ResetColor, SetForegroundColor},
    terminal::{Clear, ClearType},
};
use palette::{Clamp, IntoColor, Oklch, Srgb};

const DEFAULT_LOGO: &str = include_str!("../default-logo.txt");

#[derive(Clone, Copy, ValueEnum)]
enum PaletteName {
    /// Balanced, colorful rainbow.
    Rainbow,
    /// High-saturation rainbow that may clip a few terminal-gamut colors.
    Vivid,
    /// High-lightness, low-saturation rainbow.
    Pastel,
    /// Low-saturation rainbow for restrained terminal themes.
    Muted,
    /// Neutral grayscale with no hue variation.
    Monochrome,
}

#[derive(Parser)]
#[command(about = "Animate text with a sliding true-color rainbow")]
struct Args {
    /// Animation delay in milliseconds.
    #[arg(short, long, default_value_t = 20)]
    speed: u64,

    /// Hue shift between lines.
    #[arg(short, long, default_value_t = 6)]
    phase: i32,

    /// Hue shift between characters.
    #[arg(short = 'c', long = "char", default_value_t = 3)]
    character_step: i32,

    /// Color palette to render.
    #[arg(long, value_enum, default_value_t = PaletteName::Rainbow)]
    palette: PaletteName,

    /// Stop after this many frames instead of animating indefinitely.
    #[arg(long)]
    frames: Option<usize>,

    /// Write a complete 360-frame cache for the Bash player.
    #[arg(short, long, value_name = "PATH")]
    generate: Option<PathBuf>,

    /// File containing the text to animate. Reads stdin when piped.
    file: Option<PathBuf>,
}

fn rainbow(hue: i32, palette: PaletteName) -> Color {
    let (lightness, chroma) = match palette {
        PaletteName::Rainbow => (0.7, 0.12),
        PaletteName::Vivid => (0.8, 0.25),
        PaletteName::Pastel => (0.82, 0.07),
        PaletteName::Muted => (0.6, 0.06),
        PaletteName::Monochrome => (0.7, 0.0),
    };
    let rgb: Srgb<f32> = Oklch::new(lightness, chroma, hue.rem_euclid(360) as f32).into_color();
    let rgb: Srgb<u8> = rgb.clamp().into_format();

    Color::Rgb {
        r: rgb.red,
        g: rgb.green,
        b: rgb.blue,
    }
}

fn load_text(file: Option<PathBuf>) -> io::Result<String> {
    match file {
        Some(path) => fs::read_to_string(path),
        None if !io::stdin().is_terminal() => {
            let mut text = String::new();
            io::stdin().read_to_string(&mut text)?;
            if text.is_empty() {
                Ok(DEFAULT_LOGO.to_owned())
            } else {
                Ok(text)
            }
        }
        None => Ok(DEFAULT_LOGO.to_owned()),
    }
}

fn render_frame(output: &mut impl Write, lines: &[&str], hue: i32, args: &Args) -> io::Result<()> {
    for (row, line) in lines.iter().enumerate() {
        output
            .queue(MoveTo(0, row as u16))?
            .queue(Clear(ClearType::UntilNewLine))?;

        for (column, character) in line.chars().enumerate() {
            if character == ' ' {
                output.queue(Print(character))?;
            } else {
                let offset = row as i32 * args.phase + column as i32 * args.character_step;
                output
                    .queue(SetForegroundColor(rainbow(hue + offset, args.palette)))?
                    .queue(Print(character))?;
            }
        }
        output.queue(ResetColor)?;
    }
    output.flush()
}

fn generate_cache(path: PathBuf, lines: &[&str], args: &Args) -> io::Result<()> {
    let mut cache = io::BufWriter::new(fs::File::create(path)?);

    for hue in 0..360 {
        for (row, line) in lines.iter().enumerate() {
            for (column, character) in line.chars().enumerate() {
                if character == ' ' {
                    cache.queue(Print(character))?;
                } else {
                    let offset = row as i32 * args.phase + column as i32 * args.character_step;
                    cache
                        .queue(SetForegroundColor(rainbow(hue + offset, args.palette)))?
                        .queue(Print(character))?;
                }
            }
            cache.queue(ResetColor)?.queue(Print('\n'))?;
        }
        cache.write_all(&[0])?;
    }

    cache.flush()
}

fn main() -> io::Result<()> {
    let args = Args::parse();
    let text = load_text(args.file.clone())?;
    let lines: Vec<_> = text.lines().collect();
    if let Some(path) = args.generate.clone() {
        return generate_cache(path, &lines, &args);
    }
    let mut output = io::stdout();
    let mut hue = 0;
    let mut frame = 0;

    loop {
        render_frame(&mut output, &lines, hue, &args)?;
        frame += 1;
        if args.frames.is_some_and(|total| frame >= total) {
            return Ok(());
        }
        hue = (hue + 1) % 360;
        thread::sleep(Duration::from_millis(args.speed));
    }
}
