shader_type canvas_item;
render_mode unshaded;

uniform int effect_kind = 0;
uniform float phase : hint_range(0.0, 1.0) = 0.3;
uniform float clock_time = 0.0;
uniform vec4 tint : source_color = vec4(0.16, 0.83, 1.0, 1.0);
uniform vec4 accent : source_color = vec4(1.0, 0.65, 0.25, 1.0);
uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform bool light_surface = false;

float hash(float n) { return fract(sin(n * 127.1 + 31.7) * 43758.5453); }
float segment(vec2 p, vec2 a, vec2 b) {
    vec2 ba = b - a;
    return length(p - a - ba * clamp(dot(p - a, ba) / max(dot(ba, ba), 0.00001), 0.0, 1.0));
}
float line_light(float distance_value, float width) {
    return 1.0 - smoothstep(width * 0.4, width, distance_value);
}
float ring(vec2 p, float radius, float width) {
    return line_light(abs(length(p) - radius), width);
}

void fragment() {
    vec2 p = UV * 2.0 - 1.0;
    float t = clamp(phase, 0.0, 1.0);
    float life = smoothstep(0.0, 0.035, t) * (1.0 - smoothstep(0.56, 1.0, t));
    float sharp = 0.0;
    float glow = 0.0;
    float warm = 0.0;

    if (effect_kind == 0) {
        // Ten tapered rays and independent small embers.
        float travel = 1.0 - pow(1.0 - t, 2.8);
        for (int i = 0; i < 10; i++) {
            float k = float(i);
            float a = k * TAU / 10.0 + (hash(k) - 0.5) * 0.30;
            vec2 dir = vec2(cos(a), sin(a));
            float reach = (0.46 + hash(k + 8.0) * 0.30) * travel;
            float q = dot(p, dir);
            float side = abs(dot(p, vec2(-dir.y, dir.x)));
            float begin = reach * mix(0.10, 0.79, t);
            float envelope = max(0.0, 1.0 - abs((q - (reach + begin) * 0.5) / max((reach - begin) * 0.5, 0.001)));
            float w = (0.040 + hash(k + 2.0) * 0.025) * envelope * (1.0 - t * 0.70);
            float ray = (1.0 - smoothstep(w * 0.30, w + 0.006, side)) * step(begin, q) * step(q, reach);
            sharp += ray;
            glow += exp(-side * 75.0) * envelope * step(begin, q) * step(q, reach) * 0.4;
            vec2 ember = dir * (reach + 0.065);
            float e = length((p - ember) * vec2(1.0, 1.3));
            warm += (1.0 - smoothstep(0.005, 0.018, e)) * smoothstep(0.1, 0.3, t);
        }
        sharp += exp(-length(p) * 40.0) * 2.0 * (1.0 - smoothstep(0.03, 0.30, t));
        glow += exp(-dot(p, p) * 30.0) * (1.0 - t) * 0.32;
    } else if (effect_kind == 1) {
        float r = 0.10 + (1.0 - pow(1.0 - t, 3.0)) * 0.67;
        float a = atan(p.y, p.x);
        float wobble = sin(a * 7.0 + t * 3.0) * 0.007 * (1.0 - t);
        sharp = ring(p, r + wobble, 0.038 * (1.0 - t) + 0.006);
        sharp += ring(p, r * 0.82, 0.006) * 0.48;
        warm = ring(p, r * 1.10, 0.012) * (0.35 + 0.65 * pow(abs(sin(a * 3.0)), 9.0));
        glow = exp(-abs(length(p) - r) * 29.0) * 0.28;
        glow += exp(-dot(p, p) * 14.0) * (1.0 - t) * 0.23;
    } else if (effect_kind == 2) {
        // The emitter origin is the orb's center; it points along local +X.
        vec2 head = p * vec2(1.1, 1.0);
        float rr = length(head);
        float pulse = 0.92 + 0.08 * sin(clock_time * 8.0);
        sharp = (1.0 - smoothstep(0.075, 0.16 * pulse, rr));
        sharp += ring(head, 0.24 + sin(clock_time * 5.0) * 0.015, 0.015) * 0.72;
        float a = atan(head.y, head.x);
        sharp += ring(head, 0.32, 0.009) * pow(abs(sin(a * 1.5 - clock_time * 2.0)), 6.0) * 0.8;
        for (int i = 0; i < 4; i++) {
            float k = float(i);
            float x = clamp(-p.x, 0.0, 0.83);
            float wave = sin(x * 7.0 - clock_time * 8.0 + k * 1.8) * x * 0.10;
            float yy = (k - 1.5) * 0.058 * (1.0 - x) + wave;
            sharp += line_light(abs(p.y - yy), (1.0 - x) * 0.014) * step(p.x, -0.06) * (1.0 - smoothstep(0.4, 0.85, x));
        }
        warm = ring(head, 0.185, 0.012) * pow(abs(sin(a * 2.0 + clock_time * 3.0)), 4.0);
        glow = exp(-rr * rr * 14.0) * 0.68;
        life = 1.0;
    } else if (effect_kind == 4) {
        // A swept crescent, not a rotating rectangular texture.
        float a = atan(p.y, p.x);
        float sweep = mix(-2.80, 0.80, smoothstep(0.0, 0.66, t));
        float behind = mod(sweep - a + TAU, TAU);
        float tail = clamp(1.0 - behind / 2.50, 0.0, 1.0);
        float r = 0.59 + sin(a * 2.0 + 0.4) * 0.025;
        float width = 0.018 + 0.135 * pow(tail, 1.2);
        float blade = line_light(abs(length(p) - r), width) * step(behind, 2.5);
        sharp = blade * tail;
        sharp += ring(p, r + 0.105, 0.008) * tail * step(behind, 2.25) * 0.50;
        warm = ring(p, r - width * 0.65, 0.018) * tail * step(behind, 2.5);
        glow = exp(-abs(length(p) - r) * 23.0) * tail * step(behind, 2.5) * 0.30;
    } else if (effect_kind == 5) {
        // The local origin is the ground contact at UV.y == 0.65.
        vec2 ground = vec2(p.x, (p.y - 0.30) * 2.65);
        float spread = 0.10 + (1.0 - pow(1.0 - t, 2.5)) * 0.67;
        sharp = ring(ground, spread, 0.027 * (1.0 - t) + 0.009);
        warm = ring(ground, spread * 0.72, 0.010) * 0.75;
        glow = exp(-abs(length(ground) - spread) * 24.0) * 0.35;
        for (int i = 0; i < 7; i++) {
            float k = float(i);
            float x = (k - 3.0) * 0.17 * spread;
            float y = 0.30 + sin(k * 2.5) * 0.08;
            vec2 base = vec2(x, y);
            vec2 top = base + vec2((hash(k) - 0.5) * 0.11, -(0.20 + hash(k + 7.0) * 0.50) * sin(t * PI));
            float d = segment(p, base, top);
            sharp += line_light(d, 0.013) * (1.0 - t) * 0.70;
            warm += line_light(length(p - top), 0.022) * 0.9;
        }
        glow += exp(-length(vec2(p.x * 1.4, (p.y - 0.3) * 3.0)) * 9.0) * (1.0 - t) * 0.4;
    }

    float luminous = clamp(sharp, 0.0, 1.0);
    float edge_guard = 1.0 - smoothstep(0.91, 0.99, max(abs(p.x), abs(p.y)));
    vec3 cool = mix(tint.rgb, vec3(1.0, 0.99, 0.91), pow(luminous, 2.0) * 0.82);
    vec3 rgb = mix(cool, accent.rgb, clamp(warm, 0.0, 1.0) * 0.8);
    if (light_surface) {
        cool = tint.rgb * mix(0.40, 0.60, luminous);
        rgb = mix(cool, accent.rgb * 0.55, clamp(warm, 0.0, 1.0) * 0.8);
    }
    float alpha = clamp(luminous + warm + glow, 0.0, 1.0) * life * opacity * tint.a * edge_guard;
    COLOR = vec4(rgb * mix(0.75, 1.18, clamp(intensity * 0.5, 0.0, 1.0)), alpha * clamp(intensity, 0.0, 1.0));
}
