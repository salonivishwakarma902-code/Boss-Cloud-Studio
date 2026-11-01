import os
import sys
import glob
import subprocess
import argparse
from pathlib import Path

def run_command(cmd):
    print(f"[RUNNING] {' '.join(cmd)}")
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    print(result.stdout)
    if result.returncode != 0:
        print(f"[ERROR] Command failed with exit code {result.returncode}")
        sys.exit(result.returncode)

def main():
    parser = argparse.ArgumentParser(description="Boss Cloud 3D Engine")
    parser.add_argument("--project", required=True, help="Project directory name inside projects/")
    parser.add_argument("--engine", default="BLENDER_WORKBENCH", help="BLENDER_WORKBENCH, BLENDER_EEVEE, CYCLES")
    parser.add_argument("--start", default="1", help="Start frame")
    parser.add_argument("--end", default="900", help="End frame")
    args = parser.parse_args()

    project_dir = Path("projects") / args.project
    if not project_dir.exists():
        print(f"[ERROR] Project directory '{project_dir}' not found!")
        sys.exit(1)

    print(f"==================================================")
    print(f"      BOSS CLOUD 3D RENDER ENGINE (GITHUB CI)     ")
    print(f"  Project: {args.project}")
    print(f"  Engine : {args.engine}")
    print(f"  Frames : {args.start} to {args.end}")
    print(f"==================================================")

    frames_dir = Path("/tmp/frames")
    frames_dir.mkdir(parents=True, exist_ok=True)
    out_dir = Path("output")
    out_dir.mkdir(parents=True, exist_ok=True)

    blend_file = project_dir / "scene.blend"
    gen_script = project_dir / "generate_scene.py"

    if blend_file.exists():
        print(f"[INFO] Found Blender Scene File: {blend_file}")
        render_cmd = [
            "xvfb-run", "-a",
            "blender", "-b", str(blend_file),
            "-E", args.engine,
            "-s", args.start,
            "-e", args.end,
            "-o", f"{frames_dir}/frame_#####",
            "-a"
        ]
        run_command(render_cmd)
    elif gen_script.exists():
        print(f"[INFO] Found Procedural Python Scene: {gen_script}")
        render_cmd = [
            "xvfb-run", "-a",
            "blender", "-b",
            "-P", str(gen_script),
            "--",
            "--engine", args.engine,
            "--start", args.start,
            "--end", args.end,
            "--output", f"{frames_dir}/frame_#####"
        ]
        run_command(render_cmd)
    else:
        print(f"[ERROR] Neither scene.blend nor generate_scene.py found in {project_dir}!")
        sys.exit(1)

    # Check rendered frames
    rendered_frames = sorted(glob.glob(f"{frames_dir}/frame_*.png"))
    print(f"[INFO] Total frames rendered: {len(rendered_frames)}")
    if not rendered_frames:
        print("[ERROR] No frames were rendered!")
        sys.exit(1)

    # Audio detection
    audio_files = list(project_dir.glob("audio/*.mp3")) + list(project_dir.glob("audio/*.wav"))
    output_mp4 = out_dir / f"Boss_{args.project}_Final.mp4"

    if audio_files:
        chosen_audio = audio_files[0]
        print(f"[INFO] Attaching audio track: {chosen_audio}")
        ffmpeg_cmd = [
            "ffmpeg", "-y",
            "-framerate", "30",
            "-i", f"{frames_dir}/frame_%05d.png",
            "-i", str(chosen_audio),
            "-c:v", "libx264",
            "-pix_fmt", "yuv420p",
            "-c:a", "aac",
            "-b:a", "192k",
            "-shortest",
            str(output_mp4)
        ]
    else:
        print(f"[INFO] No audio track found, producing silent master video")
        ffmpeg_cmd = [
            "ffmpeg", "-y",
            "-framerate", "30",
            "-i", f"{frames_dir}/frame_%05d.png",
            "-c:v", "libx264",
            "-pix_fmt", "yuv420p",
            str(output_mp4)
        ]

    run_command(ffmpeg_cmd)
    print(f"[SUCCESS] Final master video produced: {output_mp4} ({output_mp4.stat().st_size / (1024*1024):.2f} MB)")

if __name__ == "__main__":
    main()
