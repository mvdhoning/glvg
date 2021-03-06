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
 * Portions created by the Initial Developer are Copyright (C) 2002-2017
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 *  M van der Honing
 *
 *)

interface

//Choose either EARCUT or GLUTESS
//{$DEFINE EARCUT}
{$DEFINE GLUTESS}

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
  fMask: integer;
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
  {$IFDEF GLUTESS}
  procedure tessBegin(which: GLenum);
  procedure tessEnd();
  procedure tessVertex(x: single; y: single; z: single; r: single; g: single; b: single; a:single);
  {$ENDIF}
  function GetOrigin: TPolygonPoint;
  procedure SetOrigin(AValue: TPolygonPoint);
public
  constructor Create();
  destructor Destroy(); override;
  procedure Add(X: single; Y: single); overload;
  procedure Add(X: single; Y: single; Z: single); overload;
  procedure Render();
  procedure RenderPath();
  procedure RenderBoundingBox();
  procedure Tesselate();
  procedure Extrude();
  procedure RenderExtruded();
  procedure CalculateBoundBox();
  procedure CleanUp();
  function IsConvex(): boolean;
  property Id: integer read Fid write Fid;
  property Mask: integer read Fmask write Fmask;
  property Points[I: integer]: TPolygonPoint read GetPoint write SetPoint;
  property Count: integer read GetCount;
  property ExtrudeDepth: single read FExtrudeDepth write FExtrudeDepth;
  property Color: TPolygonPoint read FColor write FColor;
  property BoundBoxMaxPoint: TPolygonPoint read FBoundBoxMaxPoint write FBoundBoxMaxPoint;
  property BoundBoxMinPoint: TPolygonPoint read FBoundBoxMinPoint write FBoundBoxMinPoint;
  property Origin: TPolygonPoint read GetOrigin write SetOrigin;
end;

implementation

{$IFDEF EARCUT}
uses earcut;
{$ENDIF}
{$IFDEF GLUTESS}
type
  TGLArrayd7 = array[0..6] of GLDouble;
  PGLArrayd7 = ^TGLArrayd7;
  TGLArrayvertex4 = array[0..3] of PGLArrayd7;
  PGLArrayvertex4 = ^TGLArrayvertex4;
  PGLArrayf4 = ^TGLArrayf4;
  PArray = array of PGLArrayd7;

threadvar
  PolygonClass: TPolygon;
  verarray: parray; //temporary vertex data
  countver: integer; //counter for temporary vertex data
{$ENDIF}


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

{$IFDEF GLUTESS}
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
{$ENDIF}

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
  CleanUp();
  inherited Destroy;
end;

procedure TPolygon.CleanUp();
begin
  FCount := 0;
  FVertexCount := 0;
  F3DVertexCount := 0;
  SetLength(FPoints,0);
  SetLength(FVertex,0);
  SetLength(F3DVertex,0);
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
begin
  if (FCount=0) or not((FPoints[FCount-1].x = x) and (FPoints[FCount-1].y = y)) then
  begin
    FTesselated := false;
    FCount := FCount + 1;
    SetLength(FPoints, FCount);
    FPoints[FCount-1].X := X;
    FPoints[FCount-1].Y := Y;
    FPoints[FCount-1].Z := 0.0;
    FPoints[FCount-1].R := FColor.R;
    FPoints[FCount-1].G := FColor.G;
    FPoints[FCount-1].B := FColor.B;
    FPoints[FCount-1].A := FColor.A;
  end;
end;

procedure TPolygon.Add(X: single; Y: single; Z: single);
begin
  if (FCount=0) or not((FPoints[FCount-1].x = x) and (FPoints[FCount-1].y = y) and (FPoints[FCount-1].z = z)) then
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

Procedure TPolygon.Render();
var
  loop: integer;
begin
  //draw shape
  if fTesselated then
  begin
  glbegin(GL_TRIANGLES);
  for loop:=0 to FVertexCount-1 do
  begin
    glvertex3f(FVertex[loop].X,FVertex[loop].Y,FVertex[loop].Z);
  end;
  glend;
  end else
  begin
  glbegin(GL_TRIANGLE_FAN); //works only for realy simple shapes
  for loop:=0 to High(FPoints)-1 do
  begin
    glvertex3f(FPoints[loop].X,FPoints[loop].Y,0.0);
  end;
  glend;
  end;
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
  glbegin(GL_TRIANGLES);
  for loop:=0 to F3DVertexCount-1 do
  begin
    glcolor3f(F3DVertex[loop].R,F3DVertex[loop].G,F3DVertex[loop].B);
    glvertex3f(F3DVertex[loop].X,F3DVertex[loop].Y,F3DVertex[loop].Z);
  end;
  glend;
end;

function TPolygon.IsConvex(): boolean;
var
  i,n: integer;
  sign: boolean;
  dx1,dy1,dx2,dy2,zcrossproduct: double;
begin
  result:=true;

  //if (high(fpoints)-1 < 4) then
  //  result := true;

  sign := false;
  n := high(fpoints)-1;

  for i:=0 to n do
    begin
        dx1 := fpoints[(i+1) mod n].X-fpoints[(i mod n)].X;
        dy1 := fpoints[(i+1) mod n].Y-fpoints[(i mod n)].Y;
        dx2 := fpoints[(i+2) mod n].X-fpoints[(i+1) mod n].X;
        dy2 := fpoints[(i+2) mod n].Y-fpoints[(i+1) mod n].Y;
        zcrossproduct := dx1*dy2 - dy1*dx2;
        if (i = 0) then
            sign := zcrossproduct > 0
        else if (sign <> (zcrossproduct > 0)) then
          begin
             result := false;
             break;
          end;
    end;
end;

procedure TPolygon.Tesselate();
var
  loop: integer;

{$IFDEF GLUTESS}
  tess: pointer;
  test: TGLArrayd3;
  pol: PGLArrayd7;
  polarray: parray;


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
  SetLength(verarray,countver+1);
  verarray[countver]:=vertex;
  countver:=countver+1;
  outdata := vertex;

end;
{$ENDIF}
{$IFDEF EARCUT}
var
   triangles : TTriangles;
   polygons, reverse: TMyPolygon;
   i: integer;
{$ENDIF}

begin

  {$IFDEF EARCUT}
  if fpoints<>nil then
  begin
   triangles:= nil;
   SetLength(polygons, 1);

   //remove double coords
   i:=1;
   polygons[0] := FPoints[0]; //always add first coord
   for loop := 1 to high(FPoints)-1 do //quick fix skip last point as that is the same as the first
   begin
     if not((polygons[i-1].x = FPoints[loop].x) and (polygons[i-1].y = FPoints[loop].y)) then
     begin
       SetLength(polygons, length(polygons)+1);
       polygons[i] := FPoints[loop];
       i:=i+1;
     end;
   end;


   //reverse the list of coords
   i:=0;
   setlength(reverse, length(polygons));
   for loop:=length(polygons)-1 downto 0 do
   begin
        reverse[i]:=polygons[loop];
        i:=i+1;
   end;
   setlength(polygons,0);

   FTesselated := Triangulate(reverse,triangles);
   setlength(reverse,0);

   for loop:=0 to high(triangles) do
   begin
     AddVertex(triangles[loop][0].x, triangles[loop][0].y, triangles[loop][0].z, triangles[loop][0].r, triangles[loop][0].g, triangles[loop][0].b, triangles[loop][0].a);
     AddVertex(triangles[loop][1].x, triangles[loop][1].y, triangles[loop][1].z, triangles[loop][1].r, triangles[loop][1].g, triangles[loop][1].b, triangles[loop][1].a);
     AddVertex(triangles[loop][2].x, triangles[loop][2].y, triangles[loop][2].z, triangles[loop][2].r, triangles[loop][2].g, triangles[loop][2].b, triangles[loop][2].a);
   end;
   setlength(triangles,0);

   FTesselated:=true;
  end;
  {$ENDIF}
  {$IFDEF GLUTESS}
  countver:=0;
  SetLength(verarray,0);

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

  SetLength(polarray,FCount);
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

      test[0] := FPoints[loop].X;
      test[1] := FPoints[loop].Y;
      test[2] := 0;

      polarray[loop]:=pol;
      gluTessVertex(tess, test, pol);
  end;

  gluTessEndContour(tess);
  gluTessEndPolygon(tess);
  gluDeleteTess(tess);        // delete after tessellation

  tess := nil;
  PolygonClass := nil;
  FTesselated := true;

  //clean up used memory
  if countver>=1 then
  begin
  for loop := 0 to countver-1 do
  begin
    if verarray<>nil then
    dispose(verarray[loop]);
    verarray[loop]:=nil;
  end;
  setLength(verarray,0);
  verarray:=nil;
  end;
  for loop := 0 to Fcount-1 do
  begin
    dispose(polarray[loop]);
    polarray[loop]:=nil;
  end;
  setLength(polarray,0);
  polarray:=nil;

  {$ENDIF}

end;

end.

