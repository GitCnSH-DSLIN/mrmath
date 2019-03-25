// ###################################################################
// #### This file is part of the mathematics library project, and is
// #### offered under the licence agreement described on
// #### http://www.mrsoft.org/
// ####
// #### Copyright:(c) 2011, Michael R. . All rights reserved.
// ####
// #### Unless required by applicable law or agreed to in writing, software
// #### distributed under the License is distributed on an "AS IS" BASIS,
// #### WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// #### See the License for the specific language governing permissions and
// #### limitations under the License.
// ###################################################################


unit MatrixConst;

// ##############################################
// #### Constants for the mathematic utilities
// ##############################################

interface

uses SysUtils, Types;

type
  TLinEquResult = (leOk, leSingular);
  TSVDResult = (srOk, srNoConvergence);
  TCholeskyResult = (crOk, crNoPositiveDefinite);
  TQRResult = (qrOK, qrSingular);
  TLinEquProgress = procedure(Progress : Integer) of Object;
  TLinEquProgressWOObj = procedure(Progress : Integer);
  TMtxProgress = procedure(Sender : TObject; progress : integer) of Object;

 type
   TXMMArr = Array[0..1] of double;
   PXMMArr = ^TXMMArr;

   TYMMArr = Array[0..3] of double;
   PYMMArr = ^TYMMArr;

   TMeanVarRec = record
     aMean : double;
     aVar : double;
   end;

const cDefEpsilon : double = 1e-20;
      cMinusOne : double = -1;
      cOne : double = 1;
      cOnes : Array[0..1] of double = (1, 1);
      cDivBy2 : Array[0..1] of double = (0.5, 0.5);

      cSignBits : Array[0..1] of int64 = ($7FFFFFFFFFFFFFFF, $7FFFFFFFFFFFFFFF);
      cSignBits4 : Array[0..3] of int64 = ($7FFFFFFFFFFFFFFF, $7FFFFFFFFFFFFFFF, $7FFFFFFFFFFFFFFF, $7FFFFFFFFFFFFFFF);
      cNegMaxDouble : double = -1.7e+308;
      cMaxDouble : double = 1.7e+308;

const cNegMaxDoubles : Array[0..1] of double = (-1.7e+308, -1.7e+308);
      cMaxDoubles : Array[0..1] of double = (1.7e+308, 1.7e+308);

      cMulM1Bits : Array[0..1] of Int64 = ($8000000000000000, $0);


type
  TEigenvalueConvergence = (qlOk, qlNoConverge, qlMatrixError);

type
  TMathOperationRes = (moSuccess, moFailure);

type
  TDynArrayofDoubleArray = Array of TDoubleDynArray;

type
  TConstDoubleArr = Array[0..MaxInt div sizeof(double) - 1] of double;
  PConstDoubleArr = ^TConstDoubleArr;

type
  TMatrixFunc = procedure(var Value : double);
  TMatrixObjFunc = procedure(var Value : double) of Object;
  TMatrixMtxRefFunc = procedure(var Value : double; const data : PDouble; LineWidth : integer; x, y : integer);
  TMatrixMtxRefObjFunc = procedure(var Value : double; const data : PDouble; LineWidth : integer; x, y : integer) of Object;

{$IFDEF FPC}
   {.$DEFINE ANONMETHODS}
{$ELSE}
   {$IF CompilerVersion >= 20.0}
      {$DEFINE ANONMETHODS}
   {$IFEND}
{$ENDIF}


{$IFDEF ANONMETHODS}
  TMatrixFuncRef = reference to procedure(var Value : double);
  TMatrixMtxRefFuncRef = reference to procedure(var Value : double; const data : PDouble; LineWidth : integer; x, y : integer);
{$ENDIF}

function ConvEQUProgress(value : TLinEquProgressWOObj) : TLinEquProgress;


// ###########################################
// #### Matrix multiplication constants
const cStrassenMinSize = 32;
      cCacheMtxSize = 256;
      cCacheBlkSize = 16;

{$IFDEF CPUX64}
{$DEFINE x64}
{$ENDIF}
{$IFDEF cpux86_64}
{$DEFINE x64}
{$ENDIF}
{$IFDEF x64}
type
  TASMNativeInt = NativeInt;
  TASMNativeUInt = NativeUInt;
{$ELSE}
type
  TASMNativeInt = integer;
  TASMNativeUInt = Cardinal;
{$ENDIF}

type
  TMatrixMultDestOperation = (doNone, doAdd, doSub);


// ###########################################
// #### Creates a pointer to the x, y element of the given matrix (row major)
function GenPtr(const A : PDouble; incX, incY : TASMNativeInt; const LineWidthA : TASMNativeInt) : PDouble; {$IFNDEF FPC} {$IF CompilerVersion >= 17.0} inline; {$IFEND} {$ENDIF}
function GenPtrArr(const A : PDouble; incX, incY : TASMNativeInt; const LineWidthA : TASMNativeInt) : PConstDoubleArr; {$IFNDEF FPC} {$IF CompilerVersion >= 17.0} inline; {$IFEND} {$ENDIF}

// ###########################################
// #### Sets the pointer to the next available 32bytes alligned address
// note: the function does not check if there is still enough memory allocated and left for this operation!
function AlignPtr32( A : Pointer ) : Pointer; {$IFNDEF FPC} {$IF CompilerVersion >= 17.0} inline; {$IFEND} {$ENDIF}
function AlignPtr64( A : Pointer ) : Pointer; {$IFNDEF FPC} {$IF CompilerVersion >= 17.0} inline; {$IFEND} {$ENDIF}

implementation

function GenPtr(const A : PDouble; incX, incY : TASMNativeInt; const LineWidthA : TASMNativeInt) : PDouble; {$IFNDEF FPC} {$IF CompilerVersion >= 17.0} inline; {$IFEND} {$ENDIF}
begin
     Result := A;
     inc(Result, incX);
     inc(PByte(Result), incY*LineWidthA);
end;

function GenPtrArr(const A : PDouble; incX, incY : TASMNativeInt; const LineWidthA : TASMNativeInt) : PConstDoubleArr; {$IFNDEF FPC} {$IF CompilerVersion >= 17.0} inline; {$IFEND} {$ENDIF}
begin
     Result := PConstDoubleArr(A);
     Result := @Result^[incX];
     inc(PByte(Result), incY*LineWidthA);
end;

function AlignPtr32( A : Pointer ) : Pointer;
begin
     Result := A;
     if (TASMNativeUInt(A) and $1F) <> 0 then
        Result := Pointer( TASMNativeUInt(Result) + $20 - TASMNativeUInt(Result) and $1F );
end;

function AlignPtr64( A : Pointer ) : Pointer;
begin
     Result := A;
     if (TASMNativeUInt(A) and $3F) <> 0 then
        Result := Pointer( TASMNativeUInt(Result) + $40 - TASMNativeUInt(Result) and $3F );
end;

function ConvEQUProgress(value : TLinEquProgressWOObj) : TLinEquProgress;
var meth : TMethod;
begin
     meth.Data := nil;
     meth.Code := Pointer(@Value);

     Result := TLinEquProgress(meth);
end;

end.
