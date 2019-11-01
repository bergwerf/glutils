// Copyright (c) 2016, Herman Bergwerf. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

part of glutils;

/// Shader helper
class GlShader {
  /// Rendering context
  final gl.RenderingContext _ctx;

  /// Vertex shader
  final String vertexShaderSource;

  /// Fragment shader
  final String fragmentShaderSource;

  /// Last compiled shader program
  gl.Program _shaderProgram;

  /// Attribute names
  final List<String> _attributes;

  /// Attributes mapped to their GL index.
  Map<String, int> attributes;

  /// Primary position attribute label
  String positionAttrib;

  /// Primary color attribute label
  String colorAttrib;

  /// Primary view matrix uniform label
  String viewMatrix;

  /// Uniform names
  final List<String> _uniforms;

  /// Uniforms mapped to their gl.UniformLocation
  Map<String, gl.UniformLocation> uniforms;

  /// Constructor
  GlShader(this._ctx, this.vertexShaderSource, this.fragmentShaderSource,
      this._attributes, this._uniforms);

  /// Compile shader in the given GL context.
  void compile() {
    // Vertex shader compilation
    final vs = _ctx.createShader(gl.WebGL.VERTEX_SHADER);
    _ctx.shaderSource(vs, vertexShaderSource);
    _ctx.compileShader(vs);

    // Fragment shader compilation
    final fs = _ctx.createShader(gl.WebGL.FRAGMENT_SHADER);
    _ctx.shaderSource(fs, fragmentShaderSource);
    _ctx.compileShader(fs);

    // Attach shaders to a WebGL program.
    _shaderProgram = _ctx.createProgram();
    _ctx.attachShader(_shaderProgram, vs);
    _ctx.attachShader(_shaderProgram, fs);
    _ctx.linkProgram(_shaderProgram);

    // Check if shaders were compiled properly. This is probably the most
    // painful part since there's no way to "debug" shader compilation.
    if (!_ctx.getShaderParameter(vs, gl.WebGL.COMPILE_STATUS)) {
      throw new Exception(_ctx.getShaderInfoLog(vs));
    }
    if (!_ctx.getShaderParameter(fs, gl.WebGL.COMPILE_STATUS)) {
      throw new Exception(_ctx.getShaderInfoLog(fs));
    }
    if (!_ctx.getProgramParameter(_shaderProgram, gl.WebGL.LINK_STATUS)) {
      throw new Exception(_ctx.getProgramInfoLog(_shaderProgram));
    }

    // Link shader attributes.
    attributes = new Map<String, int>();
    for (final attrib in _attributes) {
      attributes[attrib] = _ctx.getAttribLocation(_shaderProgram, attrib);
      _ctx.enableVertexAttribArray(attributes[attrib]);
    }

    // Link shader uniforms.
    uniforms = new Map<String, gl.UniformLocation>();
    for (final uniform in _uniforms) {
      uniforms[uniform] = _ctx.getUniformLocation(_shaderProgram, uniform);
    }
  }

  /// Primary view matrix index
  gl.UniformLocation get uViewMatrix => uniforms[viewMatrix];

  /// Use this shader.
  void use() {
    _ctx.useProgram(_shaderProgram);
  }
}
