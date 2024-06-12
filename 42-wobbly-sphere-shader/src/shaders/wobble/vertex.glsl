uniform float uTime;
uniform float uTimeFrequency;
uniform float uPositionFrequency;
uniform float uStrength;
uniform float uWarpTimeFrequency;
uniform float uWarpPositionFrequency;
uniform float uWarpStrength;

attribute vec4 tangent;

varying float vWobble;


#include ../includes/simplexNoise4d.glsl

float getWobble(vec3 position) {
    vec3 warpedPosition = position;
    warpedPosition += simplexNoise4d(vec4(position * uWarpPositionFrequency, uTime * uWarpTimeFrequency)) * uWarpStrength;

    return simplexNoise4d(vec4(
        warpedPosition * uPositionFrequency, // xyz
        uTime * uTimeFrequency       // w
    )) * uStrength;
}
void main() {
    // wobble
    vec3 biTangent = cross(normal, tangent.xyz);
    // neighbors technique round 2

    float shift = 0.01;
    vec3 positionA = csm_Position + tangent.xyz * shift;
    vec3 positionB = csm_Position + biTangent * shift;

    float wobble = getWobble(csm_Position);

    csm_Position += wobble * normal;        // these normals are from the base normals and they dont change
    // we need to manually compute the normals

    positionA += getWobble(positionA) * normal;     // these are the 2 neighbors
    positionB += getWobble(positionB) * normal;

    vec3 toA = normalize(positionA - csm_Position);
    vec3 toB = normalize(positionB - csm_Position);

    csm_Normal = cross(toA, toB);

    vWobble = wobble / uStrength;  // remove uStength to get -1 -> 1 back
}