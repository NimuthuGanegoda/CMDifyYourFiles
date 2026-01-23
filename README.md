# 📁 CMDifyYourFiles

Handy scripts for automating file conversion and encoding on Windows and Linux, now with recursive folder support.

---

## 🚀 Features

- **🔄 Generic File Converter**  
  Convert files to common formats (PDF, JPG, etc.). Drag-and-drop a single file or pass a folder to convert contents recursively on Windows (`convert-any-file.bat`) and Linux (`convert-any-file.sh`).

- **🎬 Video Encoder**  
  Reduce video file size for sharing (e.g., Discord). Accepts a single video or a folder and encodes all supported videos recursively: `encode-video.bat` (Windows) and `encode-video.sh` (Linux).

- **🎵 Audio Encoder**  
  Reduce audio file size for sharing. Accepts a single audio file or a folder (recursive): `audio.bat` (Windows) and `audio.sh` (Linux).

- **📄 Advanced File Tools**
  Perform advanced operations like merging PDFs, splitting PDFs, compressing PDFs, rotating PDFs, watermarking PDFs, and creating image collages. Linux only: `process-files.sh`.

---

## 🛠️ Requirements

- Windows or Linux OS
- ffmpeg installed and available in `PATH` (audio/video)
- LibreOffice (Linux) for Office → PDF conversions
- ImageMagick (`convert`, `montage`) for image format conversions and collages
- Ghostscript (`gs`) for PDF compression
- Poppler Utils (`pdfunite`, `pdfseparate`) for PDF merging and splitting
- QPDF (`qpdf`) for PDF rotation and watermarking
- (Windows) Microsoft PowerPoint/Word for Office → PDF conversions

---

## 📌 Usage

### 1. Generic File Converter

**Windows (single file):**
```cmd
convert-any-file.bat "path\to\your\file.ext"
```

**Windows (folder, recursive):**
```cmd
convert-any-file.bat "path\to\your\folder"
```

**Linux (single file):**
```bash
./convert-any-file.sh "path/to/your/file.ext"
```

**Linux (folder, recursive):**
```bash
./convert-any-file.sh "path/to/your/folder"
```

### 2. Video Encoder

**Windows (single file):**
```cmd
encode-video.bat "path\to\your\video.mp4"
```

**Windows (folder, recursive):**
```cmd
encode-video.bat "path\to\your\folder"
```

**Linux (single file):**
```bash
./encode-video.sh "path/to/your/video.mp4"
```

**Linux (folder, recursive):**
```bash
./encode-video.sh "path/to/your/folder"
```

### 3. Audio Encoder

**Windows (single file):**
```cmd
audio.bat "path\to\your\audio.mp3"
```

**Windows (folder, recursive):**
```cmd
audio.bat "path\to\your\folder"
```

**Linux (single file):**
```bash
./audio.sh "path/to/your/audio.mp3"
```

**Linux (folder, recursive):**
```bash
./audio.sh "path/to/your/folder"
```

### 4. Advanced File Tools

**Linux (Interactive Menu):**
```bash
./process-files.sh
```

**Linux (Command Line):**
```bash
# Merge PDFs
./process-files.sh merge file1.pdf file2.pdf output.pdf

# Split PDF
./process-files.sh split input.pdf output-prefix

# Compress PDF
./process-files.sh compress input.pdf output.pdf

# Image Collage
./process-files.sh collage img1.jpg img2.jpg output.jpg

# Rotate PDF
./process-files.sh rotate input.pdf +90 output.pdf

# Watermark PDF
./process-files.sh watermark input.pdf "CONFIDENTIAL" output.pdf
```

---

## 🙌 Contributions

Pull requests are welcome! If you have ideas for new CMD tools or improvements, feel free to contribute.

---

Would you like me to generate this as a downloadable file for you now? Or customize it with your GitHub username and project title?
