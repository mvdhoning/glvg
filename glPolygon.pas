unit glPolygon;

(* Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the glvggui main unit.
 *
 * The Initial Developer of the Original Code is
 * M van der Honing.
 * Portions created by the Initial Developer are Copyright (C) 2002-2004
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 *  M van der Honing
 *
 *)

interface

{$IFDEF FPC}
  {$MODE Delphi}
  {$modeswitch nestedprocvars}
{$ENDIF}

uses
  DGLOpenGL, Classes, SysUtils;

type
TPolygonPoint = packed record
  x: single;
  y: single;
  z: single;
  r: single;
  g: single;
  b: single;
  a: single;
  s: single; //u texture coord
  t: single; //v texture coord
end;

TPolygon = class
protected
  fId: integer;
  FPoints: array of TPolygonPoint; //polygon point
  FVertex: array of TPolygonPoint; //triangulated data
  FColor: TPolygonPoint;
  FExtrudeDepth: single;
  F3DVertex: array of TPolygonPoint; //3d extruded mesh
  F3DVertexCount: integer;
  FCount: integer;
  FVertexCount: integer;
  FTesselated: boolean;
  FBoundBoxMinPoint: TPolygonPoint;
  FBoundBoxMaxPoint: TPolygonPoint;
  FBoundBoxRadius: Single;
  FOrigin: TPolygonPoint;
  procedure SetPoint(I: integer; Value: TPolygonPoint);
  procedure AddVertex(x: single; y: single; z: single; r: single; g: single; b: single; a:single);
  function GetPoint(I: integer): TPolygonPoint;
  function GetCount(): integer;
  procedure tessBegin(which: GLenum);
  procedure tessEnd();
  procedure tessVertex(x: single; y: single; z: single; r: single; g: single; b: single; a:single);
  function GetOrigin: TPolygonPoint;
  procedure SetOrigin(AValue: TPolygonPoint);
public
  constructor Create();
  destructor Destroy(); override;
  procedure Add(X: single; Y: single); overload;
  procedure Add(X: single; Y: single; Z: single); overload;
  procedure Add(X: single; Y: single; Z: single; R: single; G: single; B: single; A: single); overload;
  procedure Render();
  procedure RenderPath();
  procedure RenderBoundingBox();
  procedure Tesselate();
  procedure Extrude();
  procedure RenderExtruded();
  procedure CalculateBoundBox();
  procedure CleanUp();
  property Id: integer read Fid write Fid;
  property Points[I: integer]: TPolygonPoint read GetPoint write SetPoint;
  property Count: integer read GetCount;
  property ExtrudeDepth: single read FExtrudeDepth write FExtrudeDepth;
  property Color: TPolygonPoint read FColor write FColor;
  property BoundBoxMaxPoint: TPolygonPoint read FBoundBoxMaxPoint write FBoundBoxMaxPoint;
  property BoundBoxMinPoint: TPolygonPoint read FBoundBoxMinPoint write FBoundBoxMinPoint;
  property Origin: TPolygonPoint read GetOrigin write SetOrigin;
end;

implementation

type
  TGLArrayd7 = array[0..6] of GLDouble;
  PGLArrayd7 = ^TGLArrayd7;
  TGLArrayvertex4 = array[0..3] of PGLArrayd7;
  PGLArrayvertex4 = ^TGLArrayvertex4;
  PGLArrayf4 = ^TGLArrayf4;

threadvar
  PolygonClass: TPolygon;

//TPolygon

procedure TPolygon.SetOrigin(AValue: TPolygonPoint);
begin
  FOrigin := AValue;
end;

function TPolygon.GetOrigin:TPolygonPoint;
begin
  result := FOrigin;
end;

procedure TPolygon.RenderPath;
begin
  //TODO: reimplement rendering of path
end;

procedure TPolygon.tessBegin(which: GLenum);
begin
  //glBegin(which);
end;

procedure TPolygon.tessEnd();
begin
  //glEnd();
end;

procedure TPolygon.tessVertex(x: single; y: single; z: single; r: single; g: single; b: single; a:single);
begin
  //glcolor4f(r,g,b,a);
  //glVertex3f(x,y,z);
end;

procedure TPolygon.AddVertex(x: single; y: single; z: single; r: single; g: single; b: single; a:single);
begin
  FVertexCount := FVertexCount + 1;
  SetLength(FVertex, FVertexCount);

  FVertex[FVertexCount-1].R := R;
  FVertex[FVertexCount-1].G := G;
  FVertex[FVertexCount-1].B := B;
  FVertex[FVertexCount-1].A := A;

  FVertex[FVertexCount-1].X := X;
  FVertex[FVertexCount-1].Y := Y;
  FVertex[FVertexCount-1].Z := Z;
end;

constructor TPolygon.Create();
begin
  Inherited Create();
  FCount := 0;
  FVertexCount := 0;
  FTesselated := false;
  FExtrudeDepth := 0.0;
end;

destructor TPolygon.Destroy();
begin
  FTesselated := false;
  FCount := 0;
  FVertexCount := 0;
  SetLength(FPoints, FCount);
  SetLength(FVertex, FVertexCount);
  inherited Destroy;
end;

procedure TPolygon.SetPoint(I: integer; Value: TPolygonPoint);
begin
  FTesselated := false; //check first on changed values
  FPoints[I] := Value;
end;

function TPolygon.GetPoint(I: integer): TPolygonPoint;
begin
  result := FPoints[I];
end;

function TPolygon.GetCount(): integer;
begin
  result := FCount;
end;

procedure TPolygon.Add(X: single; Y: single);
var
  CurColor: TPolygonPoint;
begin
  FTesselated := false;
  FCount := FCount + 1;
  SetLength(FPoints, FCount);
  FPoints[FCount-1].X := X;
  FPoints[FCount-1].Y := Y;
  FPoints[FCount-1].Z := 0.0;

  CurColor:=FColor;

  FPoints[FCount-1].R := CurColor.R;
  FPoints[FCount-1].G := CurColor.G;
  FPoints[FCount-1].B := CurColor.B;
  FPoints[FCount-1].A := CurColor.A;
end;

procedure TPolygon.Add(X: single; Y: single; Z: single);
begin
  FTesselated := false;
  FCount := FCount + 1;
  SetLength(FPoints, FCount);
  FPoints[FCount-1].X := X;
  FPoints[FCount-1].Y := Y;
  FPoints[FCount-1].Z := Z;
  FPoints[FCount-1].R := FColor.R;
  FPoints[FCount-1].G := FColor.G;
  FPoints[FCount-1].B := FColor.B;
  FPoints[FCount-1].A := FColor.A;
end;

procedure TPolygon.Add(X: single; Y: single; Z: single; R: single; G: single; B: single; A: single);
begin
  FTesselated := false;
  FCount := FCount + 1;
  SetLength(FPoints, FCount);
  FPoints[FCount-1].X := X;
  FPoints[FCount-1].Y := Y;
  FPoints[FCount-1].Z := Z;
  FPoints[FCount-1].R := R;
  FPoints[FCount-1].G := G;
  FPoints[FCount-1].B := B;
  FPoints[FCount-1].A := A;
end;

Procedure TPolygon.CalculateBoundBox();
var
  loop: integer;
  thirdpoint: TPolygonPoint;
  dx,dy: single;
begin
  if FCount>0 then
  begin
    FBoundBoxMinPoint.x := FPoints[0].x;
    FBoundBoxMinPoint.y := FPoints[0].y;
    FBoundBoxMaxPoint.x := FPoints[0].x;
    FBoundBoxMaxPoint.y := FPoints[0].y;
  end;

  //TODO: optimize (see TMesh);
  for loop:=0 to FCount-1  do
  begin
    if (FPoints[loop].x < FBoundBoxMinPoint.x) then
    begin
      FBoundBoxMinPoint.x := FPoints[loop].x;
    end;
    if (FPoints[loop].y < FBoundBoxMinPoint.y) then
    begin
      FBoundBoxMinPoint.y := FPoints[loop].y;
    end;

    if (FPoints[loop].x > FBoundBoxMaxPoint.x) then
    begin
      FBoundBoxMaxPoint.x := FPoints[loop].x;
    end;
    if (FPoints[loop].y > FBoundBoxMaxPoint.y) then
    begin
      FBoundBoxMaxPoint.y := FPoints[loop].y;
    end;
  end;

  //calculate radius
  thirdpoint.x := (FBoundBoxMinPoint.x+FBoundBoxMaxPoint.x)/2;
  thirdpoint.y := (FBoundBoxMinPoint.y+FBoundBoxMaxPoint.y)/2;

  //Then you calculate the three distances between cp and p1,p2,p3 using the Pythagorean theorem.
  dx := thirdpoint.x;
  dy := thirdpoint.y;
  FBoundBoxRadius := sqrt(dx*dx) + sqrt(dy*dy) /2;

end;

procedure TPolygon.CleanUp();
begin
  self.FCount:= 0;
  self.FVertexCount := 0;
  SetLength(self.FPoints,0);
  SetLength(self.FVertex,0);
end;

Procedure TPolygon.Render();
var
  loop: integer;
begin
  //draw shape
  glbegin(GL_TRIANGLES);
  for loop:=0 to FVertexCount-1 do
  begin
    glvertex3f(FVertex[loop].X,FVertex[loop].Y,FVertex[loop].Z);
  end;
  glend;
end;

procedure TPolygon.RenderBoundingBox;
begin
  glcolor4f(0,1,0,1);
  glLineWidth(1.0);
  glbegin(GL_LINES);
    glvertex3f(FBoundBoxMinPoint.X,FBoundBoxMinPoint.Y,0);
    glvertex3f(FBoundBoxMinPoint.X,FBoundBoxMaxPoint.Y,0);

    glvertex3f(FBoundBoxMinPoint.X,FBoundBoxMaxPoint.Y,0);
    glvertex3f(FBoundBoxMaxPoint.X,FBoundBoxMaxPoint.Y,0);

    glvertex3f(FBoundBoxMaxPoint.X,FBoundBoxMaxPoint.Y,0);
    glvertex3f(FBoundBoxMaxPoint.X,FBoundBoxMinPoint.Y,0);

    glvertex3f(FBoundBoxMaxPoint.X,FBoundBoxMinPoint.Y,0);
    glvertex3f(FBoundBoxMinPoint.X,FBoundBoxMinPoint.Y,0);
  glend;
end;

procedure TPolygon.Extrude();
var
  loop: integer;
begin
  if FTesselated = false then Tesselate;

  F3DVertexCount := FVertexCount*2;

  //copy front faces
  setlength(F3DVertex, F3DVertexCount);
  for loop:=0 to FVertexCount-1 do
  begin
    F3DVertex[loop]:=FVertex[loop];
  end;

  //copy back faces
  for loop:=0 to FVertexCount-1 do
  begin
    F3DVertex[loop+(FVertexCount)]:=FVertex[FVertexCount-loop-1];
    F3DVertex[loop+(FVertexCount)].Z:=F3DVertex[loop+(FVertexCount)].Z-FExtrudeDepth;
  end;

end;

Procedure TPolygon.RenderExtruded();
var
  loop: integer;
begin
  //if FTesselated = false then Tesselate;

  glbegin(GL_TRIANGLES);
  for loop:=0 to F3DVertexCount-1 do
  begin
    glcolor3f(F3DVertex[loop].R,F3DVertex[loop].G,F3DVertex[loop].B);
    glvertex3f(F3DVertex[loop].X,F3DVertex[loop].Y,F3DVertex[loop].Z);
  end;
  glend;
end;

procedure TPolygon.Tesselate();
var
  loop: integer;
  tess: pointer;
  test: TGLArrayd3;
  pol: PGLArrayd7;

procedure iTessBeginCB(which: GLenum); {$IFDEF Win32}stdcall; {$ELSE}cdecl; {$ENDIF}
begin
  PolygonClass.tessBegin(which);
end;

procedure iTessEndCB(); {$IFDEF Win32}stdcall; {$ELSE}cdecl; {$ENDIF}
begin
  //PolygonClass.tessEnd();
end;

procedure iTessEdgeCB(flag: GLboolean; lpContext: pointer); {$IFDEF Win32}stdcall; {$ELSE}cdecl; {$ENDIF}
begin
  //just do nothing to force GL_TRIANGLES !!!
end;

procedure iTessVertexCB(data: PGLArrayd7); {$IFDEF Win32}stdcall; {$ELSE}cdecl; {$ENDIF}
begin
  //PolygonClass.tessVertex(data[0], data[1], data[2], data[3], data[4], data[5],0);
  PolygonClass.AddVertex(data[0], data[1], data[2], data[3], data[4], data[5], data[6]);
end;


procedure iTessCombineCB(newVertex : PGLArrayd7; neighborVertex : Pointer; neighborWeight : Pointer; var outData : Pointer); {$IFDEF Win32}stdcall; {$ELSE}cdecl; {$ENDIF}
var
  vertex: PGLArrayd7;
  loop: integer;
  colorloop: integer;
begin
  new(vertex);

  vertex[0] := newVertex^[0];
  vertex[1] := newVertex^[1];
  vertex[2] := newVertex^[2];

  for colorloop := 3 to 6 do
  begin
    vertex[colorloop] := 0.0;
    for loop:=0 to 3 do
    begin
      if PGLArrayf4(neighborWeight)^[loop] <> 0 then
      begin
        vertex[colorloop] := vertex[colorloop] +
             PGLArrayf4(neighborWeight)^[loop] *
             PGLArrayvertex4(neighborVertex)^[loop][colorloop]
      end;
    end;
  end;

  // return output data (vertex coords and others)
  outData:= vertex;
end;

begin
  PolygonClass := Self;

  tess := gluNewTess();

  gluTessCallback(tess, GLU_TESS_BEGIN, @iTessBeginCB );
  gluTessCallback(tess, GLU_TESS_END, @iTessEndCB);
  gluTessCallback(tess, GLU_TESS_VERTEX, @iTessVertexCB);
  gluTessCallback(tess, GLU_TESS_COMBINE, @iTessCombineCB);  //does not work for font?
  gluTessCallback(tess, GLU_TESS_EDGE_FLAG_DATA, @iTessEdgeCB); //force triangles and cleanup

  gluTessProperty(tess, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_NONZERO );

  gluTessBeginPolygon(tess, nil);                   // with NULL data
  gluTessBeginContour(tess);

  for loop := 0 to FCount-1 do
  begin
      new(pol);
      pol[3]:=FPoints[loop].R; //color
      pol[4]:=FPoints[loop].G;
      pol[5]:=FPoints[loop].B;
      pol[6]:=FPoints[loop].A;

      pol[0]:=FPoints[loop].X;
      pol[1]:=FPoints[loop].Y;
      pol[2]:=0;

      test[0] := pol[0];
      test[1] := pol[1];
      test[2] := pol[2];
      gluTessVertex(tess, test, pol);
  end;

  gluTessEndContour(tess);
  gluTessEndPolygon(tess);
  gluDeleteTess(tess);        // delete after tessellation

  PolygonClass := nil;
  FTesselated := true;

end;

end.

