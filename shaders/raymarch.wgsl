struct Sphere {
    transform: vec4<f32>, // xyz = pos, w = radius
    color: vec4<f32>,     // rgb = color
};

struct Scene {
    spheres: array<Sphere, 16>,
    count: u32,
};

struct Uniforms {
    resolution: vec2<f32>,
    time: f32,
    dt: f32,
    // camera.x = yaw, camera.y = pitch, camera.z = dist, w = COUNT
    camera: vec4<f32>, 
};

@group(0) @binding(0) var<uniform> uni: Uniforms;
@group(1) @binding(0) var<uniform> scene: Scene;

fn sdSphere(p: vec3<f32>, s: Sphere) -> f32 {
    return length(p - s.transform.xyz) - s.transform.w;
}
fn sdPlane(p: vec3<f32>, h: f32) -> f32 {
    return p.y + h;
}

fn map(p: vec3<f32>) -> vec2<f32> {
    var d = sdPlane(p, 1.0); 
    var mat = 0.0;
    
    // Utilisation du count venant du Uniform Buffer (pas du Scene buffer)
    let count = u32(uni.camera.w);

    for (var i = 0u; i < count; i = i + 1u) {
        let s = scene.spheres[i];
        let sphereDist = sdSphere(p, s);
        if (sphereDist < d) {
            d = sphereDist;
            mat = f32(i) + 1.0;
        }
    }
    return vec2<f32>(d, mat);
}

fn get_normal(p: vec3<f32>) -> vec3<f32> {
    let e = vec2<f32>(0.001, 0.0);
    let n = vec3<f32>(
        map(p + e.xyy).x - map(p - e.xyy).x,
        map(p + e.yxy).x - map(p - e.yxy).x,
        map(p + e.yyx).x - map(p - e.yyx).x
    );
    return normalize(n);
}

fn get_material_color(mat_id: f32, p: vec3<f32>) -> vec3<f32> {
    if (mat_id < 0.5) {
        let checker = floor(p.x) + floor(p.z);
        return mix(vec3(0.2), vec3(0.9), step(0.5, abs(checker % 2.0)));
    } else {
        let index = u32(mat_id - 1.0);
        let count = u32(uni.camera.w);
        if (index < count) { return scene.spheres[index].color.rgb; }
    }
    return vec3(1.0, 0.0, 1.0);
}

@fragment
fn fs_main(@builtin(position) fragCoord: vec4<f32>) -> @location(0) vec4<f32> {
    let uv = (fragCoord.xy - uni.resolution * 0.5) / min(uni.resolution.x, uni.resolution.y);

    let yaw = uni.camera.x;
    let pitch = uni.camera.y;
    let dist = uni.camera.z;

    let cam_pos = vec3<f32>(
        sin(yaw) * cos(pitch), 
        sin(pitch), 
        cos(yaw) * cos(pitch)
    ) * dist;
    
    let cam_target = vec3<f32>(0.0, 0.0, 0.0);
    let cam_forward = normalize(cam_target - cam_pos);
    let cam_right = normalize(cross(cam_forward, vec3<f32>(0.0, 1.0, 0.0)));
    let cam_up = cross(cam_right, cam_forward);
    
    let rd = normalize(cam_right * uv.x - cam_up * uv.y + cam_forward * 1.5);

    var t = 0.0;
    var mat_id = -1.0;
    var hit = false;
    
    for (var i = 0; i < 128; i++) {
        let p = cam_pos + rd * t;
        let res = map(p);
        if (res.x < 0.001) { hit = true; mat_id = res.y; break; }
        t += res.x;
        if (t > 100.0) { break; }
    }

    let sky = mix(vec3(0.7, 0.8, 0.9), vec3(0.6, 0.7, 0.8), uv.y * 0.5 + 0.5);
    var color = sky;

    if (hit) {
        let p = cam_pos + rd * t;
        let n = get_normal(p);
        let light_dir = normalize(vec3<f32>(1.0, 2.0, -1.0));
        
        let diff = max(dot(n, light_dir), 0.0);
        let amb = 0.2;
        let albedo = get_material_color(mat_id, p);
        
        var sha = 1.0;
        var st = 0.02;
        for(var j=0; j<32; j++) {
            let h = map(p + light_dir * st).x;
            if(h < 0.001) { sha = 0.2; break; }
            st += h;
        }

        color = albedo * (diff * sha + amb);
    }

    return vec4<f32>(pow(color, vec3(1.0/2.2)), 1.0);
}