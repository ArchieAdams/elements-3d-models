use <write/Write.scad>
dev = true;

element = "O";  // ["H","He","Li","Be","B","C","N","O","F","Ne","Na","Mg","Al","Si","P","S","Cl","Ar","K","Ca"]
font = "write/orbitron.dxf";//["write/Letters.dxf":Letters,"write/orbitron.dxf":orbitron,"write/BlackRose.dxf":BlackRose,"write/knewave.dxf":knewave,"write/braille.dxf":braille]
font_depth = 2; // [.5:8]
// The width of each ring
ring_width=5; // [3:20]
// The space between each ring
ring_spacing=2; // [.5:8]
// The Height of the center ring
ring_height=6; // [6:15]
// The radius of the center hole
center_radius=12; // [1:50]
// The mesh resolution
mesh_resolution=120; // [20:120]
// The ring to ring height increase
ring_height_step=.5;
// The radius of a pin
pin_radius=2.45;
// The width of material covering the pin hole
pin_cap_width=4;
// The pin end to hole wall width
pin_cap_gap=.45;
// radius of the pin holes
pin_hole_radius=3;
// How deep the cross extends into the ring (added parameter)
cross_depth = 0.6; 
cross_rise = 1.6;

$fn=mesh_resolution; 

// Module to create a cross shape for electrons
module electron_cross(size, depth) {
    cross_thickness = size / 3;
    rotate([0,0,45]){
        union() {
            cube([size, cross_thickness, depth+cross_rise], center=true);
            cube([cross_thickness, size, depth+cross_rise], center=true);
        }
    }
}

// Module to create socket/pocket for cross to fit into
module electron_cross_socket(size, depth) {
    cross_thickness = size / 3;
    // Make socket slightly larger for clearance
    clearance = 0.01;
    rotate([0,0,45]){
        union() {
            cube([size+clearance, cross_thickness+clearance, depth+clearance], center=true);
            cube([cross_thickness+clearance, size+clearance, depth+clearance], center=true);
        }
    }
}

if (element=="H") draw_gimbal("H", "1", [1,0,0,0,0,0,0]);
if (element=="He") draw_gimbal("He", "2", [2,0,0,0,0,0,0]);
if (element=="Li") draw_gimbal("Li", "3", [2,1,0,0,0,0,0]);
if (element=="Be") draw_gimbal("Be", "4", [2,2,0,0,0,0,0]);
if (element=="B") draw_gimbal("B", "5", [2,3,0,0,0,0,0]);
if (element=="C") draw_gimbal("C", "6", [2,4,0,0,0,0,0]);
if (element=="N") draw_gimbal("N", "7", [2,5,0,0,0,0,0]);
if (element=="O") draw_gimbal("O", "8", [2,6,0,0,0,0,0]);
if (element=="F") draw_gimbal("F", "9", [2,7,0,0,0,0,0]);
if (element=="Ne") draw_gimbal("Ne", "10", [2,8,0,0,0,0,0]);
if (element=="Na") draw_gimbal("Na", "11", [2,8,1,0,0,0,0]);
if (element=="Mg") draw_gimbal("Mg", "12", [2,8,2,0,0,0,0]);
if (element=="Al") draw_gimbal("Al", "13", [2,8,3,0,0,0,0]);
if (element=="Si") draw_gimbal("Si", "14", [2,8,4,0,0,0,0]);
if (element=="P") draw_gimbal("P", "15", [2,8,5,0,0,0,0]);
if (element=="S") draw_gimbal("S", "16", [2,8,6,0,0,0,0]);
if (element=="Cl") draw_gimbal("Cl", "17", [2,8,7,0,0,0,0]);
if (element=="Ar") draw_gimbal("Ar", "18", [2,8,8,0,0,0,0]);
if (element=="K") draw_gimbal("K", "19", [2,8,8,1,0,0,0]);
if (element=="Ca") draw_gimbal("Ca", "20", [2,8,8,2,0,0,0]);
module draw_gimbal(element, atomic_number, electrons_on_each_ring)
{
active_rings = [ for (e = electrons_on_each_ring) if (e > 0) e ];
number_of_rings = len(active_rings)+1;
// translate everything so that it rests on z=0
// and loop over all rings
translate(v=[0, 0, ring_height*.5]) union()
for (ring = [0 : number_of_rings-1]) 
    let(
        ir=center_radius+(ring_width+ring_spacing)*ring,
        or=center_radius+(ring_width+ring_spacing)*(ring+1)-ring_spacing,
        odd=(ring%2), 
        even=((ring+1)%2)
    ) {
	// translate each new ring so that the pins get printed
	// resting on the next ring's hole wall
	translate(v=[0, 0, ring*ring_height_step*.5]) union() {
        difference() {
            intersection() {
                difference() {
                    difference() {
                        union() {
                            sphere(r=or);
                            // the last ring does not have protruding pins
                            if (ring != number_of_rings-1) rotate(v=[even, odd, 0], a=90)
                                cylinder(r=pin_radius, 
                                h=(or*2-ir+ring_spacing)*2-(pin_cap_width+pin_cap_gap),
                                    center=true);
                        }
                        // the inner-most ring does not have pin holes
                        if (ring==0) translate(v=[0, 0, ring_height/3]) cylinder(r=center_radius+ring_width*0.5, h=10, center=false);
                        else union() {
                            sphere(r=ir);
                            rotate(v=[odd, even, 0], a=90)
                                cylinder(r=pin_hole_radius, h=or*2-pin_cap_width, center=true);
                        }
                    }
                    if (ring != number_of_rings-1)
                        rotate(v=[even, odd, 0], a=90)
                            rotate(v=[0,0,1], a=45)
                                cube(size=[pin_radius, pin_radius,
                               (or+ring_width+ring_spacing)*2],
                               center=true);
                }
                // make each ring thicker than the last so that the
                // pin is still centered even though it is printed
                // resting on the next ring's hole wall
                cube(size=[(or+ring_width+ring_spacing)*2,
                         (or+ring_width+ring_spacing)*2,
                   ring_height+(ring_height_step*ring)],
                   center=true);
            }
            // Cut pockets for the crosses to sit in
            draw_electron_sockets(or, ir, ring_height, ring_height_step, ring, ring_width, electrons_on_each_ring);
        }
        // Add electron crosses AFTER creating the pockets
        draw_electrons_geometry(or, ir, ring_height, ring_height_step, ring, ring_width, electrons_on_each_ring);
    }
    // Add text for center ring
    if (ring==0 && electrons_on_each_ring[0]) {
        writetext(element,atomic_number,center_radius,ring_height,ring,font_depth);
    }
}
}

// Module to cut sockets/pockets for crosses
module draw_electron_sockets(or, ir, ring_height, ring_height_step, ring, ring_width, electrons_on_each_ring)
{
    for (current_ring = [0:6]){
        electrons_on_current_ring = electrons_on_each_ring[current_ring];
        if (ring==current_ring+1 && (electrons_on_current_ring>0)) {
            // Reduce depth for ring 1 to avoid pin overlap
            for (electron = [1 : electrons_on_current_ring]){
                actual_depth = depth_calculator(current_ring, electron, electrons_on_current_ring, cross_depth);
                echo(current_ring, electron, actual_depth);
                rotate(a=360/electrons_on_current_ring*electron, v=[0,0,1])
                    translate(v=[0.5*(or+ir)-0.5, 0, (ring_height+(ring_height_step*ring))/2 - actual_depth/2])
                        electron_cross_socket(ring_width/1.5, actual_depth);
            }
        }
    }
}

// Module to create electron cross geometry that gets added to rings
module draw_electrons_geometry(or, ir, ring_height, ring_height_step, ring, ring_width, electrons_on_each_ring)
{
    for (current_ring = [0:6]){
        electrons_on_current_ring = electrons_on_each_ring[current_ring];
        if (ring==current_ring+1 && (electrons_on_current_ring>0)) {
            // Reduce depth for ring 1 to avoid pin overlap
            for (electron = [1 : electrons_on_current_ring]){
                actual_depth = depth_calculator(current_ring, electron, electrons_on_current_ring, cross_depth);
                rotate(a=360/electrons_on_current_ring*electron, v=[0,0,1])
                    translate(v=[0.5*(or+ir)-0.5, 0, (ring_height+(ring_height_step*ring))/2 - actual_depth/2])
                
//                          write(str(electron),center=true,h=2);
                        electron_cross(ring_width/1.5, actual_depth);
                
            }
        }
    }
}

module writetext(element,atomic_number,center_radius,ring_height,ring,font_depth){
    translate([0,0,0])
    translate([0,center_radius/3,0.5*(ring_height+(2*ring_height_step*ring))]){
        write(element,h=center_radius,t=font_depth,center=true);
        translate([0,-center_radius/1.5-center_radius/3,0])
            write(atomic_number,h=center_radius/2,t=font_depth,center=true);
    }
}

function depth_calculator(ring_number, electron_number, total_electrons, cross_depth) = 
    let(
        depth_offset = 0.5,
        even = total_electrons % 2
    )
    (ring_number == 1 && (even == 0 && 
     (electron_number ==  total_electrons/2|| electron_number == total_electrons))||(even==1&&electron_number==total_electrons))
    ? cross_depth - depth_offset
    : cross_depth;