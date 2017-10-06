unit caticon;

{$mode delphi}

// cat icon by twitter (https://twitter.github.io/twemoji/) licensed under CC-BY

interface

uses
  Classes, SysUtils, glvg;

var
  cat: TglvgGroup;
  ear: TglvgPolygon;

  procedure loadcat();

implementation

procedure loadcat();
begin
  cat:=TglvgGroup.Create();
  cat.Transform:=TTransform.Create('matrix(1.25 0 0 -1.25 0 45)');

  cat.AddElement(TglvgPolygon.Create());
  cat.Element[cat.Count-1].Style.Color.SetColor('#FFCB4E');
  cat.Element[cat.Count-1].Style.FillType := glvgSolid;
  cat.Element[cat.Count-1].Style.LineType := glvgNone;
  cat.Element[cat.Count-1].Polygon.Path:='M373.641-150.044c12.197,69.222,14.359,171.213,0,180.497c-14.359,9.273-114.597-25.213-135.555-71.259c-11.435,3.038-35.123,4.54-35.123,4.54s-22.903-1.502-34.327-4.54C147.678,5.239,46.655,39.726,32.307,30.453c-14.359-9.284-12.22-111.275,0-180.497c0,0-11.002-22.517-11.002-101.831l182.044,45.136v9.523l182.044-55.034C385.394-172.561,373.641-150.044,373.641-150.044';
  cat.Element[cat.Count-1].Init;

  cat.AddElement(TglvgPolygon.Create());
  cat.Element[cat.Count-1].Style.Color.SetColor('#FFD882');
  cat.Element[cat.Count-1].Style.FillType := glvgSolid;
  cat.Element[cat.Count-1].Style.LineType := glvgNone;
  cat.Element[cat.Count-1].Polygon.Path:='M270.626-176.009c-23.723,0-48.617-5.427-67.277-14.575c-18.648,9.148-43.543,14.575-67.265,14.575c-113.004,0-114.779-58.027-114.779-75.822c0-17.738,22.38-114.153,181.669-114.153s182.42,96.04,182.42,113.778C385.394-234.411,383.619-176.009,270.626-176.009';
  cat.Element[cat.Count-1].Init;

  cat.AddElement(TglvgPolygon.Create());
  cat.Element[cat.Count-1].Style.Color.SetColor('#F28F20');
  cat.Element[cat.Count-1].Style.FillType := glvgSolid;
  cat.Element[cat.Count-1].Style.LineType := glvgNone;
  cat.Element[cat.Count-1].Polygon.Path:='M264.482-48.259c24.69,27.113,76.015,47.468,86.551,44.885c8.556-2.059,7.225-72.658,0.364-113.061C322.236-68.079,264.482-48.259,264.482-48.259';
  cat.Element[cat.Count-1].Init;

  cat.AddElement(TglvgPolygon.Create());
  cat.Element[cat.Count-1].Style.Color.SetColor('#F28F20');
  cat.Element[cat.Count-1].Style.FillType := glvgSolid;
  cat.Element[cat.Count-1].Style.LineType := glvgNone;
  cat.Element[cat.Count-1].Polygon.Path:='M142.217-48.259C117.55-21.146,66.213-0.791,55.677-3.374c-8.567-2.059-7.236-72.658-0.353-113.061C84.486-68.079,142.217-48.259,142.217-48.259';
  cat.Element[cat.Count-1].Init;

  cat.AddElement(TglvgPolygon.Create());
  cat.Element[cat.Count-1].Style.Color.SetColor('#FAAA35');
  cat.Element[cat.Count-1].Style.FillType := glvgSolid;
  cat.Element[cat.Count-1].Style.LineType := glvgNone;
  cat.Element[cat.Count-1].Polygon.Path:='M248.94-184.178c0,53.396-20.582,147.911-45.966,147.911s-45.966-94.515-45.966-147.911c0-53.419,20.582-22.756,45.966-22.756S248.94-237.596,248.94-184.178';
  cat.Element[cat.Count-1].Init;

  cat.AddElement(TglvgPolygon.Create());
  cat.Element[cat.Count-1].Style.Color.SetColor('#2A2F33');
  cat.Element[cat.Count-1].Style.FillType := glvgSolid;
  cat.Element[cat.Count-1].Style.LineType := glvgNone;
  cat.Element[cat.Count-1].Polygon.Path:='M169.068-150.044c0-12.572-10.286-22.756-22.983-22.756c-12.686,0-22.972,10.183-22.972,22.756c0,12.561,10.286,22.733,22.972,22.733C158.783-127.312,169.068-137.483,169.068-150.044';
  cat.Element[cat.Count-1].Init;

  //translate(10.02) //TODO implement transformation on shapes to render eye at correct position
  cat.AddElement(TglvgPolygon.Create());
  cat.Element[cat.Count-1].Transform := TTransform.Create('translate(10.02)');
  cat.Element[cat.Count-1].Style.Color.SetColor('#2A2F33');
  cat.Element[cat.Count-1].Style.FillType := glvgSolid;
  cat.Element[cat.Count-1].Style.LineType := glvgNone;
  cat.Element[cat.Count-1].Polygon.Path:='M283.074-150.044c0-12.572-10.286-22.756-22.983-22.756c-12.686,0-22.972,10.183-22.972,22.756c0,12.561,10.286,22.733,22.972,22.733C272.788-127.312,283.074-137.483,283.074-150.044';
  cat.Element[cat.Count-1].Init;

  cat.AddElement(TglvgPolygon.Create());
  cat.Element[cat.Count-1].Style.Color.SetColor('#F28F20');
  cat.Element[cat.Count-1].Style.FillType := glvgSolid;
  cat.Element[cat.Count-1].Style.LineType := glvgNone;
  cat.Element[cat.Count-1].Polygon.Path:='M203.202-285.156c-6.292,0-11.378,5.086-11.378,11.378v32.711c0,6.292,5.086,11.378,11.378,11.378s11.378-5.086,11.378-11.378v-32.711C214.579-280.07,209.493-285.156,203.202-285.156';
  cat.Element[cat.Count-1].Init;

  cat.AddElement(TglvgPolygon.Create());
  cat.Element[cat.Count-1].Style.Color.SetColor('#F28F20');
  cat.Element[cat.Count-1].Style.FillType := glvgSolid;
  cat.Element[cat.Count-1].Style.LineType := glvgNone;
  cat.Element[cat.Count-1].Polygon.Path:='M249.282-310.266c-45.534,0-56.4,31.414-56.9,32.95c-1.957,5.973,1.297,12.402,7.282,14.347c5.951,1.957,12.265-1.24,14.29-7.1c0.501-1.32,9.967-24.314,55.046-15.303c6.224,1.274,12.174-2.776,13.392-8.932c1.24-6.167-2.765-12.151-8.92-13.38C264.494-309.493,256.461-310.266,249.282-310.266';
  cat.Element[cat.Count-1].Init;

  cat.AddElement(TglvgPolygon.Create());
  cat.Element[cat.Count-1].Style.Color.SetColor('#F28F20');
  cat.Element[cat.Count-1].Style.FillType := glvgSolid;
  cat.Element[cat.Count-1].Style.LineType := glvgNone;
  cat.Element[cat.Count-1].Polygon.Path:='M156.678-310.266c-7.191,0-15.212,0.774-24.201,2.583c-6.155,1.229-10.16,7.214-8.92,13.38c1.217,6.155,7.157,10.217,13.392,8.932c45.534-9.079,55.159,14.45,55.546,15.462c2.23,5.78,8.727,8.841,14.541,6.724s8.932-8.397,6.94-14.245C213.453-278.977,202.212-310.266,156.678-310.266';
  cat.Element[cat.Count-1].Init;

  cat.AddElement(TglvgPolygon.Create());
  cat.Element[cat.Count-1].Style.Color.SetColor('#292F33');
  cat.Element[cat.Count-1].Style.FillType := glvgSolid;
  cat.Element[cat.Count-1].Style.LineType := glvgNone;
  cat.Element[cat.Count-1].Polygon.Path:='M248.713-202.291c0-20.002-36.591-45.272-45.739-45.272c-9.125,0-45.727,25.27-45.727,45.272c0,20.025,25.532,18.113,45.727,18.113C223.181-184.178,248.713-182.266,248.713-202.291';
  cat.Element[cat.Count-1].Init;

  cat.AddElement(TglvgPolygon.Create());
  cat.Element[cat.Count-1].Style.Color.SetColor('#F39120');
  cat.Element[cat.Count-1].Style.FillType := glvgSolid;
  cat.Element[cat.Count-1].Style.LineType := glvgNone;
  cat.Element[cat.Count-1].Polygon.Path:='M385.246-319.972c-3.152,0-6.292,1.308-8.545,3.857c-0.341,0.398-36.193,39.845-118.443,52.611c-6.212,0.967-10.468,6.781-9.5,12.982c0.967,6.212,6.793,10.422,12.993,9.5c4.164-0.637,8.226-1.354,12.197-2.116c82.398-15.974,118.318-56.206,119.876-57.981c4.119-4.733,3.63-11.924-1.104-16.054C390.571-319.05,387.897-319.972,385.246-319.972';
  cat.Element[cat.Count-1].Init;

  cat.AddElement(TglvgPolygon.Create());
  cat.Element[cat.Count-1].Style.Color.SetColor('#F39120');
  cat.Element[cat.Count-1].Style.FillType := glvgSolid;
  cat.Element[cat.Count-1].Style.LineType := glvgNone;
  cat.Element[cat.Count-1].Polygon.Path:='M259.977-263.595c-4.619,0-8.977,2.844-10.684,7.43c-2.173,5.905,0.853,12.447,6.736,14.62c62.316,23.029,138.365,2.15,141.665,1.24c6.053-1.695,9.58-7.953,7.908-14.006c-1.673-6.053-7.93-9.58-13.995-7.93c-0.728,0.205-72.34,19.786-127.681-0.66C262.616-263.367,261.285-263.595,259.977-263.595';
  cat.Element[cat.Count-1].Init;

  cat.AddElement(TglvgPolygon.Create());
  cat.Element[cat.Count-1].Style.Color.SetColor('#F39120');
  cat.Element[cat.Count-1].Style.FillType := glvgSolid;
  cat.Element[cat.Count-1].Style.LineType := glvgNone;
  cat.Element[cat.Count-1].Polygon.Path:='M20.793-319.972c3.152,0,6.292,1.308,8.545,3.857c0.341,0.398,36.193,39.845,118.443,52.611c6.212,0.967,10.468,6.781,9.5,12.982c-0.967,6.212-6.793,10.422-12.982,9.5c-4.176-0.637-8.238-1.354-12.208-2.116c-82.398-15.974-118.318-56.206-119.876-57.981c-4.119-4.733-3.63-11.924,1.104-16.054C15.468-319.05,18.142-319.972,20.793-319.972';
  cat.Element[cat.Count-1].Init;

  cat.AddElement(TglvgPolygon.Create());
  cat.Element[cat.Count-1].Style.Color.SetColor('#F39120');
  cat.Element[cat.Count-1].Style.FillType := glvgSolid;
  cat.Element[cat.Count-1].Style.LineType := glvgNone;
  cat.Element[cat.Count-1].Polygon.Path:='M146.04-263.595c4.619,0,8.977,2.844,10.684,7.43c2.173,5.905-0.853,12.447-6.736,14.62c-62.316,23.029-138.365,2.15-141.665,1.24C2.27-242-1.257-248.257,0.415-254.31s7.93-9.58,13.995-7.93c0.728,0.205,72.34,19.786,127.681-0.66C143.4-263.367,144.731-263.595,146.04-263.595';
  cat.Element[cat.Count-1].Init;

end;

end.

