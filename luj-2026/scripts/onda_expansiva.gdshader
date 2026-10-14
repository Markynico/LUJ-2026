shader_type canvas_item;

// — Uniforms — //
uniform float circle_width: hint_range(0.0, 1.0, 0.05) = 0.15;
uniform float alpha_boost: hint_range(1.0, 5.0, 0.1) = 2.0;

// Reemplazamos wait_time y speed por un simple progreso
uniform float progress: hint_range(0.0, 2.0) = 0.0;

// — Functions — //
void fragment() {
  float dist = distance(UV, vec2(0.5));
  
  // Eliminamos mod() y TIME. Usamos 'progress'
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