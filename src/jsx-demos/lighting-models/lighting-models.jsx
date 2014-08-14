"use strict";

var renderable = {};

var program = null;

var torusModel = null;
var teapotModel = null;

var backgroundColor = Native.newColorRGB(); //! color[0, 0, 0]

function Model(nativeModel, x, y, z) {
	this.obj = nativeModel;

	this.obj.transform.translate(x, y, z);

	this.render = function(program) {
		program.setUniform("ModelMatrix", nativeModel.transform);
		nativeModel.render();
	};
}

function initShaders() {
	program = ProgramFactory.createProgram("Lighting Program");
	program.attachShader("shaders/lighting-models.frag");
	program.attachShader("shaders/lighting-models.vert");
	program.link();

    Synthclipse.createControls(program);
    Synthclipse.createScriptControls();
    
   program.loadPreset("Default");
   Synthclipse.loadPreset("Default");
}

renderable.init = function() {
	initShaders();
	
	var torus = GeometryFactory.createTorus(0.5, 1.0, 32, 32);
	torusModel = new Model(torus, 2, 0, 0);
	
	var teapot = GeometryFactory.createTeapot(5, 0.5);
	teapotModel = new Model(teapot, -2, -1, 0);

	var sphericalCamera = CameraManager.getSphericalCamera();
	sphericalCamera.setPosition(0.0, 0.0, -6.0);

	CameraManager.useSphericalCamera();
	CameraManager.setZoomFactor(0.4);
	
	gl.enable(gl.DEPTH_TEST);
};

renderable.display = function() {
	gl.clearColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, 1.0);
	gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

	program.use();
	program.applyUniforms();

	torusModel.render(program);
	teapotModel.render(program);	
};

Synthclipse.setRenderable(renderable);

/*!
 * <preset name="Default">
 *  backgroundColor = 0.41568628, 0.52156866, 0.65882355
 * </preset>
 */
