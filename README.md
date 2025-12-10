# WebGPU Ray Marching Scene Editor

![Demo](demo.gif)
Gif demonstrating the Scene Editor

### [Launch Live Demo](https://suva14.github.io/raymarching/)

This project is an interactive 3D scene editor built with WebGPU and WGSL. It implements a real-time Ray Marching renderer allowing users to define, visualize, and manipulate spherical primitives through a synchronized UI panel and direct viewport interaction.

## Features
* **Real-time Ray Marching:** High-performance rendering using Signed Distance Functions (SDFs).
* **Dynamic Scene Management:** Add, remove, and modify objects (Position, Radius, Color) in real-time.
* **Viewport Interaction:** Implements "Click-to-Select" logic using CPU-side ray casting to pick objects directly in the 3D view.
* **Synced Uniforms:** Bidirectional updates between the JavaScript UI state and WGSL Uniform Buffers.
* **Camera Controls:** Mouse-driven orbital navigation (drag to rotate, scroll to zoom).
* **Integrated Editor:** Live shader code visualization via CodeMirror.

## Tech Stack
* **Core:** WebGPU, WGSL, JavaScript (ES6+)
* **Styling:** Tailwind CSS
* **Dependencies:** CodeMirror (Syntax highlighting)

## Local Development
Due to WebGPU security protocols (COOP/COEP) and local file fetching, this project requires a local web server to run.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/suva14/raymarching.git
    cd raymarching
    ```

2.  **Start a local server:**
    ```bash
    python -m http.server
    ```

3.  **Run the application:**
    Open your browser (Chrome/Edge recommended for WebGPU support) and navigate to `http://localhost:8000`.
