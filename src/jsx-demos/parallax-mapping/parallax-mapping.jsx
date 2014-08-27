/**
 * This demo compares:
 * - Bump Mapping
 * - Parallax Mapping
 * - Steep Parallax Mapping (Parallax Occlussion Mapping)
 * 
 * It is based on the examples from:
 * http://content.gpwiki.org/D3DBook:(Lighting)_Per-Pixel_Lighting
 * 
 * Textures come from:
 * http://wiki.thedarkmod.com/index.php?title=Photoshop_3:_Stone_Wall_Phase_1
 */
"use strict";

var renderable = {};
var program = null;
var boxModel = null;

function Model(nativeModel, x, y, z) {
	this.obj = nativeModel;

	this.obj.transform.translate(x, y, z);

	this.render = function(program) {
		program.setUniform("ModelMatrix", nativeModel.transform);
		nativeModel.render();
	};
}

function initShaders() {
	program = ProgramFactory.createProgram("MyProgram");
	program.attachShader("shaders/parallax-mapping.frag");
	program.attachShader("shaders/parallax-mapping.vert");
	program.link();
		
    Synthclipse.createControls(program);
    
   program.loadPreset("Default");
}

renderable.init = function() {
	initShaders();
	
	var box = GeometryFactory.createCube(1.0);
	boxModel = new Model(box, 0, 0, 0);
	
	gl.clearColor(0.41568628, 0.52156866, 0.65882355, 1.0);
	gl.enable(gl.DEPTH_TEST);

	var sphericalCamera = CameraManager.getSphericalCamera();
	sphericalCamera.setPosition(1, 1, 1);
	sphericalCamera.setDistance(2.0);

	CameraManager.useSphericalCamera();
};

renderable.display = function() {
	gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

	program.use();
	program.applyUniforms();

	boxModel.render(program);
};

Synthclipse.setRenderable(renderable);