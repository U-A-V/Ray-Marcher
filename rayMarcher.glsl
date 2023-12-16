
float sdfBox(vec3 P, vec3 r){
    return length(max(abs(P)-r,0.0));
}

float sdfSphere(vec3 p, vec3 r){
    return length(p-r);
}

float map(in vec3 pos){
    float d = sdfBox(pos,20.0*vec3(0.04,0.03,0.02))-0.005;
    float d1 = sdfSphere(pos, vec3(0.0,0.5,0.0)) - 0.5;
    float d2 = pos.y + 0.5;
    float t = min(d,d1);
    return min(t,d2);
}

vec3 calcNormal(in vec3 pos){
    vec2 e = vec2(0.0001,0.0);
    return normalize(vec3(map(pos+e.xyy)-map(pos-e.xyy),
                          map(pos+e.yxy)-map(pos-e.yxy),
                          map(pos+e.yyx)-map(pos-e.yyx)));
}

float castRay(in vec3 ro, vec3 rd){
    float t=0.0;
    for(int i=0;i<100;i++){
        vec3 pos = ro + t*rd;
        float h = map(pos);
        if(h<0.001)
            break;
        t+=h;
        if(t>20.0) break;
    }
    
    if(t>20.0) t=-1.0;
    return t;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    vec2 p = (2.0*fragCoord-iResolution.xy)/iResolution.y;

    float an = 5.0*iMouse.x/iResolution.x;
    vec3 ro= vec3(2.0*sin(an),0.0,2.0*cos(an));
    
    vec3 ta = vec3(0.0,0.0,0.0);
    vec3 ww = normalize(ta-ro);
    vec3 uu = normalize(cross(ww,vec3(0,1,0)));
    vec3 vv = normalize(cross(uu,ww));
    
    vec3 rd= normalize(p.x*uu+p.y*vv+1.5*ww);
    
   
    float t = castRay( ro, rd);
    vec3 col = vec3(0.65, 0.75, 0.9) - -0.5*rd.y;
    if(t>0.0){
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal(pos);
        
        vec3 matt = vec3(0.18);
        
        vec3 sun_dir = normalize(vec3(0.8,0.4,0.2));
        float sun_dif = clamp(dot(nor,sun_dir), 0.0, 1.0);
        float sun_sha = step(castRay(pos + nor*0.001, sun_dir),0.0);
        float sky_dif = clamp(0.5 + 0.5*dot(nor, vec3(0.0,1.0,0.0)), 0.0, 1.0);
        float bou_dif = clamp(0.5 + 0.5*dot(nor, vec3(0.0,-1.0,0.0)), 0.0, 1.0);
        
        col = matt*vec3(7.0,4.5,3.0)*sun_dif*sun_sha;
        col+= matt*vec3(0.5,0.8,0.9)*sky_dif;
        col+= matt*vec3(0.7,0.3,0.2)*bou_dif;
        
    }
    
    col = pow(col, vec3(0.4545));
    
    fragColor = vec4(col,1.0);
}
