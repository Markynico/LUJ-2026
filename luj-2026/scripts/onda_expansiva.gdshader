shader_type canvas_item;

// — Uniforms Originales — //
uniform float circle_width: hint_range(0.0, 1.0, 0.05) = 0.15;
uniform float alpha_boost: hint_range(1.0, 5.0, 0.1) = 2.0;
uniform float progress: hint_range(0.0, 2.0) = 0.0;

// — Nuevos Uniforms para el Aura Oscilante — //
uniform bool enable_aura = false;
// Controla qué tan rápido se mueven las ondas
uniform float aura_speed: hint_range(0.0, 20.0, 0.1) = 10.0;
// Controla qué tan fuerte es la distorsión de la onda
uniform float aura_strength: hint_range(0.0, 0.1, 0.001) = 0.02;
// Controla cuántas sub-ondas se generan (frecuencia)
uniform float aura_frequency: hint_range(0.0, 100.0, 1.0) = 40.0;

// — Functions — //
void fragment() {
    float dist = distance(UV, vec2(0.5));
  
    // Efecto de aura/ripple: distorsionamos el cálculo de la distancia
    if (enable_aura) {
        // La matemática de sin(distancia - tiempo) crea ondas concéntricas
        dist += sin(dist * aura_frequency - TIME * aura_speed) * aura_strength;
    }
  
    float mod_dist = dist - progress + 0.5;
   
    // Background transparency
    COLOR.a = 0.0; 
   
    // Ring effect
    float ring_alpha = 1.0 - step(0.5, mod_dist); 
    ring_alpha += step(0.5 - circle_width / 2.0, mod_dist) - 1.0; 
    ring_alpha -= 2.0 * dist; 
    ring_alpha *= alpha_boost; 
   
    // Applying the transparency of the effect
    if (ring_alpha > 0.0) {
        COLOR.a = ring_alpha; 
    }
}