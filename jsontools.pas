(********************************************************)
(*                                                      *)
(*  Json Tools Pascal Unit                              *)
(*  A small json parser with no dependencies            *)
(*                                                      *)
(*  http://www.getlazarus.org/json                      *)
(*  Dual licence GPLv3 LGPLv3 released August 2019      *)
(*                                                      *)
(********************************************************)
(*  migrated to delphi5
JSON Tools for Pascal https://www.getlazarus.org/json/

We have decided to write a small yet capable JSON parser and JSON builder. A JSON parser converts plain text in Javascript object notation format into a set of nodes which can be queried. A JSON builder allows you to dynamically create and manipulate nodes, then output those nodes as valid JSON text.
Update
We've added a new page to test our our new parser in comparison to several other pascal based parsers. You can read more about these tests here.

The results show that our parser is dramatically better than the other parsers we were able to find and test. Better both in terms of speed and correctness. Though we believe our test are fair, they are by no means exhaustive, some please be mindful of that fact when considering our results.
Why use JSON?
JSON is a standardized text data format that has increasingly becoming ubiquitous. It works on any computer system, its portable, its concise, and its human readable and editable. Many web based API calls require either JSON content as post data, or return JSON content as results. Many desktop systems are switching to JSON as a file format for configurations, settings, layouts, or other data persisted to disk.
Why write a JSON parser when one already exists?
The reason we wrote this parser and builder comes down to two primary reasons.
we wanted a very simple interface to work with JSON in Pascal that works in the manner to which we are accustomed. More on this below.

We wanted to write a fairly small yet complete solution cleanly implemented in one class with no dependencies other than the SysUtils and Classes units.
How does our JSON parser make working with JSON easier?
Our parser is very easy to use. Simply add the JsonTools unit to your uses clause, then you can parse a valid JSON document like so:
N := TJsonNode.Create;
N.Parse(YourJsonText);
Where you are done with your TJsonNode simply write Free. You only need to free a TJsonNode if you created it directly.
N.Free;
In addition to calling Parse you can also use these methods to parse a JSON document.
N.Value := YourJsonText;
Or if the JSON is in a file you might write:
N.LoadFromFile(YourJsonFileName);
These methods do the same thing as Parse. They build a tree of JSON nodes by parsing JSON data. To get your JSON text data back out of any node you can simply write:
WriteLn(N.Value);
And the nodes are converted back into a nicely formatted JSON document. If you wanted to print out each node, then the entire document you might write:
N.Value := '[ "Hello", "World!" ]';
for C in N do
  WriteLn(C.Value);
WriteLn(N.Value);
Which would result in the following output:
"Hello"
"World!"
[
    "Hello",
    "World!"
]
If you are unsure if your source JSON text is valid, you can write this bit of code to check if it is correct:
S := '{ this is not valid json }';
if N.TryParse(S) then
  // Do something with your data
else
  // Your input did not contain valid JSON text
More things you can do with JSON
Now that we know how this JSON object can parse text, let's look at an example of how it can navigate and manipulate JSON nodes. Here is a bit of JSON text data we'll be using in a few examples to follow.
{
    "name": "Alice Brown",
    "sku": "54321",
    "price": 199.95,
    "shipTo": {
        "name": "Bob Brown",
        "address": "456 Oak Lane",
        "city": "Pretendville",
        "state": "HI",
        "zip": "98999"
    },
    "billTo": {
        "name": "Alice Brown",
        "address": "456 Oak Lane",
        "city": "Pretendville",
        "state": "HI",
        "zip": "98999"
    }
}
If this data were in a file named orders.json, we could use it like so:
N.LoadFromFile('orders.json');
WriteLn('The price is ', N.Find('price').Value);
WriteLn('The customer is ', N.Find('billTo/name').Value);
The output of which would be:
The price is 199.95
The customer is "Alice Brown"
If you wanted to change the shipTo to match the billTo, you could simply write:
N.Find('shipTo').Value := N.Find('billTo').Value;
And all the nodes under billTo will be copied over the shipTo. What this means is that my object can parse text on the node level, allowing you to compose a JSON document from several sources or move and copy data easily. You could also load and save various child nodes from separate files or streams. How cool is that?

If you just want to change the name of the customer you could write:
N.Find('billTo/name').AsString := 'Joe Schmoe';
Notice we are using AsString above instead of Value. This is due to the nature of the Value property. Whenever you set Value the current node will try to parse the incoming value as a JSON fragment. The input value of 'Joe Schmoe' is not valid JSON. To let our object know we intend to set a string value we can use the AsString property.

If you do not want to use AsString would need to write this statement instead, which makes 'Joe Schmoe' a valid JSON string:
N.Find('billTo/name').Value := '"Joe Schmoe"';
Notice we've enclosed out new name in " double quote characters. Double quotes are required to create JSON strings. Since we've added double quote characters the second statement now feeds a valid value to our Value property.

Here are some examples of valid values you can use when setting the Value property of a node.
N.Value := 'true';   // node becomes a bool node
N.Value := '3.1415'; // node becomes a number node
N.Value := 'null';   // node becomes a null node
N.Value := '[]';     // node becomes an array
N.Value := '{}';     // node becomes an object
In the examples above N is changed to a different kind of node with each statement. If N is the root node, the first three statements will fail, as a root node is required to be either an object or array.

Alternately, the five statements below do the exact same thing as the five statements above, but with a bit of added type safety:
N.AsBoolean := True;
N.AsNumber := 3.1415;
N.AsNull;
N.AsArray;
N.AsObject;
Note that AsNull, AsArray, and AsObject do not have an := assignment operator. This is because the Value of each of these types is fixed. A null node is null, an array node is array, and an object node is object. These three statements have the effect of converting the node kind and resetting its value.
Switching to another node
As noted in the last section, attempting to set the root node to a value that is not an object or an array is an error. The JSON standard dictates that the root level of all JSON objects must either be an object or an array

To switch to another node you might write:
N := N.Find('shipTo/name');
N.Add('first', 'Joe');
N.Add('last', 'Schmoe');
If the shipTo/name was a string kind, it will switch to an object kind when a node is added. After temporarily switching nodes, to get a reference back to our root we could type:
WriteLn(N.Value);
N := N.Root;
And now we can be sure N refers to the root node again. The output of above snippet would have been:
{
    "first": "Joe",
    "last": "Schmoe"
}
Adding and removing nodes
Nodes can be added or removed programatically using special purpose methods. If you want to add a value to an object (or an array) you can write:
N.Add('note', 'Customer requested we change the ship to address');
This would add the following to our JSON object:
"note": "Customer requested we change the ship to address"
In our pascal code, if N is an array then the first parameter will be ignored as arrays in JSON do not have named values for their child nodes.

Also notice when we use the Add method we do not need to use JSON strings. We can just use normal strings and they will be converted to JSON format internally. This internal formatting allows us to add strings with multiple lines or other format encoding, and internally they will be retained as JSON compatible strings.

Add is overloaded allow you to add bool, number, string, and more:
N.Add('discount', -8.50);   // adds a number node 
N.Add('verified', True);    // adds a bool node 
N.Add('wishlist', nkArray); // adds an array node
A particular feature of JSON is that it only allows one node of a given name at specific level. This means you Add the same name again, then the existing node will be returned, and its value will be changed to match the second argument of Add.

A child node can be removed either using the Delete method or Clear method.
N.Delete('note');   // removes the note node
N.Delete('shipTo'); // removes the shipTo node
To delete items in an array, simply use the string representation of the array index:
N.ToArray.Add('note', 'Please call the customer');
N.Delete('0');
In the example above our N is converted to an array and an item is added. Since arrays do not use names to index their child nodes, the first argument 'note' is discarded. The second line in the example removes the 0 (arrays are 0 based) item. If N was not as array before the first line line, then its values are discarded and it would only contain our string "Please call the customer".

To remove all child nodes of an object or array, simply type:
N.Clear;
This will remove every node below the current node. Clear has no effect on null, bool, number, or string nodes.
The basic properties of every JSON node
Every node at its core stores the following information:
property Root: TJsonNode     // the root of your JSON document (read only)
property Parent: TJsonNode   // the parent of your JSON node (read only)
property Kind: TJsonNodeKind // the kind of node, such as object, array, string etc (read write)
property Name: string        // the name of node (read write)
property Value: string       // the value of the node in JSON form (read write)
The Kind property uses an enumerated type defined as one of these possible values:
nkObject,  nkArray, nkBool, nkNull, nkNumber, nkString
When Kind is set to a different than current value, the node is reset. For object and array kinds this means all children are removed. For bool, null, number, and string kinds the reset values are false, null, 0, and "" respectively.

If a duplicate Name is set, then the existing node of the same name is removed and replaced by the current node. You can only set the name of a node if the parent is an object, otherwise any attempts to change the name are ignored.

When Value is set, internally the value you pass is parsed as JSON and the entire value portion of the node is replaced, potentially changing the node kind in the process. It is important to note that the root node value must be a valid JSON object or array. It cannot be any other kind.

Here are a few examples of how the Value property can be used.
N.Child('sku').Value := '[ "54321", "98765" ]'; // sku becomes an array of values
N.Find('shipTo/name').Value := '{ "id": 5028, "primary": true }'; // name becomes object
In addition to being able to use the for...in enumerator on any node, you can also use these three properties to enumerate child nodes:
function Child(Index: Integer): TJsonNode;     // get a child node by index
function Child(const Name: string): TJsonNode; // get a child node by name
property Count: Integer;                       // return the number of child nodes
Note that Child is not the same as the previously mentioned Find method. The Find method searches a path, while the Child method looks for an exact name match directly under the current node.
*)



unit JsonTools;






interface


uses
  Classes, SysUtils;

{ EJsonException is the exception type used by TJsonNode. It is thrown
  during parse if the string is invalid json or if an attempt is made to
  access a non collection by name or index. }

type
  EJsonException = class(Exception);

{ TJsonNodeKind is 1 of 6 possible values described below }

  TJsonNodeKind = (
    { Object such as { }
    nkObject,
    { Array such as [ ] }
    nkArray,
    { The literal values true or false }
    nkBool,
    { The literal value null }
    nkNull,
    { A number value such as 123, 1.23e2, or -1.5 }
    nkNumber,
    { A string such as "hello\nworld!" }
    nkString);

  TJsonNode = class;

{ TJsonNodeEnumerator is used to enumerate 'for ... in' statements }

  TJsonNodeEnumerator = object
  private
    FNode: TJsonNode;
    FIndex: Integer;
  public
    procedure Init(Node: TJsonNode);
    function GetCurrent: TJsonNode;
    function MoveNext: Boolean;
    property Current: TJsonNode read GetCurrent;
  end;

{ TJsonNode is the class used to parse, build, and navigate a json document.
  You should only create and free the root node of your document. The root
  node will manage the lifetime of all children through methods such as Add,
  Delete, and Clear.

  When you create a TJsonNode node it will have no parent and is considered to
  be the root node. The root node must be either an array or an object. Attempts
  to convert a root to anything other than array or object will raise an
  exception.

  Note: The parser supports unicode by converting unicode characters escaped as
  values such as \u20AC. If your json string has an escaped unicode character it
  will be unescaped when converted to a pascal string.

  See also:

  JsonStringDecode to convert a JSON string to a normal string
  JsonStringEncode to convert a normal string to a JSON string }

  TJsonNode = class
  private
    FStack: Integer;
    FParent: TJsonNode;
    FName: string;
    FKind: TJsonNodeKind;
    FValue: string;
    FList: TList;
    procedure ParseObject(Node: TJsonNode; var C: PChar);
    procedure ParseArray(Node: TJsonNode; var C: PChar);
    procedure Error(const Msg: string = '');
    function Format(const Indent: string): string;
    function FormatCompact: string;
    function Add(Kind: TJsonNodeKind; const Name, Value: string): TJsonNode; overload;
    function GetRoot: TJsonNode;
    procedure SetKind(Value: TJsonNodeKind);
    function GetName: string;
    procedure SetName(const Value: string);
    function GetValue: string;
    function GetCount: Integer;
    function GetAsJson: string;
    function GetAsArray: TJsonNode;
    function GetAsObject: TJsonNode;
    function GetAsNull: TJsonNode;
    function GetAsBoolean: Boolean;
    procedure SetAsBoolean(Value: Boolean);
    function GetAsString: string;
    procedure SetAsString(const Value: string);
    function GetAsNumber: Double;
    procedure SetAsNumber(Value: Double);
  public
    { A parent node owns all children. Only destroy a node if it has no parent.
      To destroy a child node use Delete or Clear methods instead. }
    destructor Destroy; override;
    { GetEnumerator adds 'for ... in' statement support }
    function GetEnumerator: TJsonNodeEnumerator;
    { Loading and saving methods }
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);
    { Convert a json string into a value or a collection of nodes. If the
      current node is root then the json must be an array or object. }
    procedure Parse(const Json: string);
    { The same as Parse, but returns true if no exception is caught }
    function TryParse(const Json: string): Boolean;
    { Add a child node by node kind. If the current node is an array then the
      name parameter will be discarded. If the current node is not an array or
      object the Add methods will convert the node to an object and discard
      its current value.

      Note: If the current node is an object then adding an existing name will
      overwrite the matching child node instead of adding. }
    function Add(const Name: string; K: TJsonNodeKind = nkObject): TJsonNode; overload;
    function Add(const Name: string; B: Boolean): TJsonNode; overload;
    function Add(const Name: string; const N: Double): TJsonNode; overload;
    function Add(const Name: string; const S: string): TJsonNode; overload;
    { Delete a child node by index or name }
    procedure Delete(Index: Integer); overload;
    procedure Delete(const Name: string); overload;
    { Remove all child nodes }
    procedure Clear;
    { Get a child node by index. EJsonException is raised if node is not an
      array or object or if the index is out of bounds.

      See also: Count }
    function Child(Index: Integer): TJsonNode; overload;
    { Get a child node by name. If no node is found nil will be returned. }
    function Child(const Name: string): TJsonNode; overload;
    { Search for a node using a path string }
    function Find(const Path: string): TJsonNode;
    { Format the node and all its children as json }
    function ToString: string;
    { Root node is read only. A node the root when it has no parent. }
    property Root: TJsonNode read GetRoot;
    { Parent node is read only }
    property Parent: TJsonNode read FParent;
    { Kind can also be changed using the As methods.

      Note: Changes to Kind cause Value to be reset to a default value. }
    property Kind: TJsonNodeKind read FKind write SetKind;
    { Name is unique within the scope }
    property Name: string read GetName write SetName;
    { Value of the node in json e.g. '[]', '"hello\nworld!"', 'true', or '1.23e2' }
    property Value: string read GetValue write Parse;
    { The number of child nodes. If node is not an object or array this
      property will return 0. }
    property Count: Integer read GetCount;
    { AsJson is the more efficient version of Value. Text returned from AsJson
      is the most compact representation of the node in json form.

      Note: If you are writing a services to transmit or receive json data then
      use AsJson. If you want friendly human readable text use Value. }
    property AsJson: string read GetAsJson write Parse;
    { Convert the node to an array }
    property AsArray: TJsonNode read GetAsArray;
    { Convert the node to an object }
    property AsObject: TJsonNode read GetAsObject;
    { Convert the node to null }
    property AsNull: TJsonNode read GetAsNull;
    { Convert the node to a bool }
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    { Convert the node to a string }
    property AsString: string read GetAsString write SetAsString;
    { Convert the node to a number }
    property AsNumber: Double read GetAsNumber write SetAsNumber;
  end;

{ JsonValidate tests if a string contains a valid json format }
function JsonValidate(const Json: string): Boolean;
{ JsonNumberValidate tests if a string contains a valid json formatted number }
function JsonNumberValidate(const N: string): Boolean;
{ JsonStringValidate tests if a string contains a valid json formatted string }
function JsonStringValidate(const S: string): Boolean;
{ JsonStringEncode converts a pascal string to a json string }
function JsonStringEncode(const S: string): string;
{ JsonStringEncode converts a json string to a pascal string }
function JsonStringDecode(const S: string): string;
{ JsonStringEncode converts a json string to xml }
function JsonToXml(const S: string): string;

implementation

resourcestring
  SNodeNotCollection = 'Node is not a container';
  SRootNodeKind = 'Root node must be an array or object';
  SIndexOutOfBounds = 'Index out of bounds';
  SParsingError = 'Error while parsing text';

type
  TJsonTokenKind = (tkEnd, tkError, tkObjectOpen, tkObjectClose, tkArrayOpen,
    tkArrayClose, tkColon, tkComma, tkNull, tkFalse, tkTrue, tkString, tkNumber);

  TJsonToken = object
    Head: PChar;
    Tail: PChar;
    Kind: TJsonTokenKind;
    function Value: string;
  end;

const
  Hex = ['0'..'9', 'A'..'F', 'a'..'f'];

function StrToFloatDef (str: string; fDef: Single): Single;
begin
  try
    Result:= StrToFloat(str);
  except
    Result:= fDef;
  end;
end;

function TJsonToken.Value: string;
begin
  case Kind of
    tkEnd: Result := #0;
    tkError: Result := #0;
    tkObjectOpen: Result := '{';
    tkObjectClose: Result := '}';
    tkArrayOpen: Result := '[';
    tkArrayClose: Result := ']';
    tkColon: Result := ':';
    tkComma: Result := ',';
    tkNull: Result := 'null';
    tkFalse: Result := 'false';
    tkTrue: Result := 'true';
  else
    SetString(Result, Head, Tail - Head);
  end;
end;

function NextToken(var C: PChar; out T: TJsonToken): Boolean;
begin
  if C^ > #0 then
    if C^ <= ' ' then
    repeat
      Inc(C);
      if C^ = #0 then
        Break;
    until C^ > ' ';
  T.Head := C;
  T.Tail := C;
  T.Kind := tkEnd;
  if C^ = #0 then begin
    Result:=FALSE; Exit;
  end;
  if C^ = '{' then
  begin
    Inc(C);
    T.Tail := C;
    T.Kind := tkObjectOpen;
    Result:=TRUE; Exit;
  end;
  if C^ = '}' then
  begin
    Inc(C);
    T.Tail := C;
    T.Kind := tkObjectClose;
    Result:=TRUE; Exit;
  end;
  if C^ = '[' then
  begin
    Inc(C);
    T.Tail := C;
    T.Kind := tkArrayOpen;
    Result:=TRUE; Exit;
  end;
  if C^ = ']' then
  begin
    Inc(C);
    T.Tail := C;
    T.Kind := tkArrayClose;
    Result:=TRUE; Exit;
  end;
  if C^ = ':' then
  begin
    Inc(C);
    T.Tail := C;
    T.Kind := tkColon;
    Result:=TRUE; Exit;
  end;
  if C^ = ',' then
  begin
    Inc(C);
    T.Tail := C;
    T.Kind := tkComma;
    Result:=TRUE; Exit;
  end;
  if (C[0] = 'n') and (C[1] = 'u') and (C[2] = 'l') and (C[3] = 'l')  then
  begin
    Inc(C, 4);
    T.Tail := C;
    T.Kind := tkNull;
    Result:=TRUE; Exit;
  end;
  if (C[0] = 'f') and (C[1] = 'a') and (C[2] = 'l') and (C[3] = 's') and (C[4] = 'e')  then
  begin
    Inc(C, 5);
    T.Tail := C;
    T.Kind := tkFalse;
    Result:=TRUE; Exit;
  end;
  if (C[0] = 't') and (C[1] = 'r') and (C[2] = 'u') and (C[3] = 'e')  then
  begin
    Inc(C, 4);
    T.Tail := C;
    T.Kind := tkTrue;
    Result:=TRUE; Exit;
  end;
  if C^ = '"'  then
  begin
    repeat
      Inc(C);
      if C^ = '\' then
      begin
        Inc(C);
        if C^ = '"' then
          Inc(C)
        else if C^ = 'u' then
          if not ((C[1] in Hex) and (C[2] in Hex) and (C[3] in Hex) and (C[4] in Hex)) then
          begin
            T.Tail := C;
            T.Kind := tkError;
            Result:=FALSE; Exit;
          end;
      end;
    until C^ in [#0, #10, #13, '"'];
    if C^ = '"' then
    begin
      Inc(C);
      T.Tail := C;
      T.Kind := tkString;
      Result:=TRUE; Exit;
    end;
    T.Tail := C;
    T.Kind := tkError;
    Result:=FALSE; Exit;
  end;
  if C^ in ['-', '0'..'9'] then
  begin
    if C^ = '-' then
      Inc(C);
    if C^ in ['0'..'9'] then
    begin
      while C^ in ['0'..'9'] do
        Inc(C);
      if C^ = '.' then
      begin
        Inc(C);
        if C^ in ['0'..'9'] then
        begin
          while C^ in ['0'..'9'] do
            Inc(C);
        end
        else
        begin
          T.Tail := C;
          T.Kind := tkError;
          Result:=FALSE; Exit;
        end;
      end;
      if C^ in ['E', 'e'] then
      begin
        Inc(C);
        if C^ = '+' then
          Inc(C)
        else if C^ = '-' then
          Inc(C);
        if C^ in ['0'..'9'] then
        begin
          while C^ in ['0'..'9'] do
            Inc(C);
        end
        else
        begin
          T.Tail := C;
          T.Kind := tkError;
          Result:=FALSE; Exit;
        end;
      end;
      T.Tail := C;
      T.Kind := tkNumber;
      Result:=TRUE; Exit;
    end;
  end;
  T.Kind := tkError;
  Result := False;
end;

{ TJsonNodeEnumerator }

procedure TJsonNodeEnumerator.Init(Node: TJsonNode);
begin
  FNode := Node;
  FIndex := -1;
end;

function TJsonNodeEnumerator.GetCurrent: TJsonNode;
begin
  if FNode.FList = nil then
    Result := nil
  else if FIndex < 0 then
    Result := nil
  else if FIndex < FNode.FList.Count then
    Result := TJsonNode(FNode.FList[FIndex])
  else
    Result := nil;
end;

function TJsonNodeEnumerator.MoveNext: Boolean;
begin
  Inc(FIndex);
  if FNode.FList = nil then
    Result := False
  else
    Result := FIndex < FNode.FList.Count;
end;

{ TJsonNode }

destructor TJsonNode.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TJsonNode.GetEnumerator: TJsonNodeEnumerator;
begin
  Result.Init(Self);
end;

procedure TJsonNode.LoadFromStream(Stream: TStream);
var
  S: string;
  I: Int64;
begin
  I := Stream.Size - Stream.Position;
  S := '';
  SetLength(S, I);
  Stream.Read(PChar(S)^, I);
  Parse(S);
end;

procedure TJsonNode.SaveToStream(Stream: TStream);
var
  S: string;
  I: Int64;
begin
  S := Value;
  I := Length(S);
  Stream.Write(PChar(S)^, I);
end;

procedure TJsonNode.LoadFromFile(const FileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStream(F);
  finally
    F.Free;
  end;
end;

procedure TJsonNode.SaveToFile(const FileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(F);
  finally
    F.Free;
  end;
end;

const
  MaxStack = 1000;

procedure TJsonNode.ParseObject(Node: TJsonNode; var C: PChar);
var
  T: TJsonToken;
  N: string;
begin
  Inc(FStack);
  if FStack > MaxStack then
    Error;
  while NextToken(C, T) do
  begin
    case T.Kind of
      tkString: N := JsonStringDecode(T.Value);
      tkObjectClose:
        begin
          Dec(FStack);
          Exit;
        end
    else
      Error;
    end;
    NextToken(C, T);
    if T.Kind <> tkColon then
      Error;
    NextToken(C, T);
    case T.Kind of
      tkObjectOpen: ParseObject(Node.Add(nkObject, N, ''), C);
      tkArrayOpen: ParseArray(Node.Add(nkArray, N, ''), C);
      tkNull: Node.Add(nkNull, N, 'null');
      tkFalse: Node.Add(nkBool, N, 'false');
      tkTrue: Node.Add(nkBool, N, 'true');
      tkString: Node.Add(nkString, N, T.Value);
      tkNumber: Node.Add(nkNumber, N, T.Value);
    else
      Error;
    end;
    NextToken(C, T);
    if T.Kind = tkComma then
      Continue;
    if T.Kind = tkObjectClose then
    begin
      Dec(FStack);
      Exit;
    end;
    Error;
  end;
  Error;
end;

procedure TJsonNode.ParseArray(Node: TJsonNode; var C: PChar);
var
  T: TJsonToken;
begin
  Inc(FStack);
  if FStack > MaxStack then
    Error;
  while NextToken(C, T) do
  begin
    case T.Kind of
      tkObjectOpen: ParseObject(Node.Add(nkObject, '', ''), C);
      tkArrayOpen: ParseArray(Node.Add(nkArray, '', ''), C);
      tkNull: Node.Add(nkNull, '', 'null');
      tkFalse: Node.Add(nkBool, '', 'false');
      tkTrue: Node.Add(nkBool, '', 'true');
      tkString: Node.Add(nkString, '', T.Value);
      tkNumber: Node.Add(nkNumber, '', T.Value);
      tkArrayClose:
        begin
          Dec(FStack);
          Exit;
        end
    else
      Error;
    end;
    NextToken(C, T);
    if T.Kind = tkComma then
      Continue;
    if T.Kind = tkArrayClose then
    begin
      Dec(FStack);
      Exit;
    end;
    Error;
  end;
  Error;
end;

procedure TJsonNode.Parse(const Json: string);
var
  C: PChar;
  T: TJsonToken;
begin
  Clear;
  C := PChar(Json);
  if FParent = nil then
  begin
    if NextToken(C, T) and (T.Kind in [tkObjectOpen, tkArrayOpen]) then
    begin
      try
        if T.Kind = tkObjectOpen then
        begin
          FKind := nkObject;
          ParseObject(Self, C);
        end
        else
        begin
          FKind := nkArray;
          ParseArray(Self, C);
        end;
        NextToken(C, T);
        if T.Kind <> tkEnd then
          Error;
      except
        Clear;
        raise;
      end;
    end
    else
      Error(SRootNodeKind);
  end
  else
  begin
    NextToken(C, T);
    case T.Kind of
      tkObjectOpen:
        begin
          FKind := nkObject;
          ParseObject(Self, C);
        end;
      tkArrayOpen:
        begin
          FKind := nkArray;
          ParseArray(Self, C);
        end;
      tkNull:
        begin
          FKind := nkNull;
          FValue := 'null';
        end;
      tkFalse:
        begin
          FKind := nkBool;
          FValue := 'false';
        end;
      tkTrue:
        begin
          FKind := nkBool;
          FValue := 'true';
        end;
      tkString:
        begin
          FKind := nkString;
          FValue := T.Value;
        end;
      tkNumber:
        begin
          FKind := nkNumber;
          FValue := T.Value;
        end;
    else
      Error;
    end;
    NextToken(C, T);
    if T.Kind <> tkEnd then
    begin
      Clear;
      Error;
    end;
  end;
end;

function TJsonNode.TryParse(const Json: string): Boolean;
begin
  try
    Parse(Json);
    Result := True;
  except
    Result := False;
  end;
end;

procedure TJsonNode.Error(const Msg: string = '');
begin
  FStack := 0;
  if Msg = '' then
    raise EJsonException.Create(SParsingError)
  else
    raise EJsonException.Create(Msg);
end;

function TJsonNode.GetRoot: TJsonNode;
begin
  Result := Self;
  while Result.FParent <> nil do
    Result := Result.FParent;
end;

procedure TJsonNode.SetKind(Value: TJsonNodeKind);
begin
  if Value = FKind then Exit;
  case Value of
    nkObject: AsObject;
    nkArray: AsArray;
    nkBool: AsBoolean;
    nkNull: AsNull;
    nkNumber: AsNumber;
    nkString: AsString;
  end;
end;

function TJsonNode.GetName: string;
begin
  if FParent = nil then begin
    Result:='0';Exit;
  end;
  if FParent.FKind = nkArray then
    Result := IntToStr(FParent.FList.IndexOf(Self))
  else
    Result := FName;
end;

procedure TJsonNode.SetName(const Value: string);
var
  N: TJsonNode;
begin
  if FParent = nil then
    Exit;
  if FParent.FKind = nkArray then
    Exit;
  N := FParent.Child(Value);
  if N = Self then
    Exit;
  FParent.FList.Remove(N);
  FName := Value;
end;

function TJsonNode.GetValue: string;
begin
  if FKind in [nkObject, nkArray] then
    Result := Format('')
  else
    Result := FValue;
end;

function TJsonNode.GetAsJson: string;
begin
  if FKind in [nkObject, nkArray] then
    Result := FormatCompact
  else
    Result := FValue;
end;

function TJsonNode.GetAsArray: TJsonNode;
begin
  if FKind <> nkArray then
  begin
    Clear;
    FKind := nkArray;
    FValue := '';
  end;
  Result := Self;
end;

function TJsonNode.GetAsObject: TJsonNode;
begin
  if FKind <> nkObject then
  begin
    Clear;
    FKind := nkObject;
    FValue := '';
  end;
  Result := Self;
end;

function TJsonNode.GetAsNull: TJsonNode;
begin
  if FParent = nil then
    Error(SRootNodeKind);
  if FKind <> nkNull then
  begin
    Clear;
    FKind := nkNull;
    FValue := 'null';
  end;
  Result := Self;
end;

function TJsonNode.GetAsBoolean: Boolean;
begin
  if FParent = nil then
    Error(SRootNodeKind);
  if FKind <> nkBool then
  begin
    Clear;
    FKind := nkBool;
    FValue := 'false';
    Result:=FALSE; Exit;
  end;
  Result := FValue = 'true';
end;

procedure TJsonNode.SetAsBoolean(Value: Boolean);
begin
  if FParent = nil then
    Error(SRootNodeKind);
  if FKind <> nkBool then
  begin
    Clear;
    FKind := nkBool;
  end;
  if Value then
    FValue := 'true'
  else
    FValue := 'false';
end;

function TJsonNode.GetAsString: string;
begin
  if FParent = nil then
    Error(SRootNodeKind);
  if FKind <> nkString then
  begin
    Clear;
    FKind := nkString;
    FValue := '""';
    Result:= '';Exit;
  end;
  Result := JsonStringDecode(FValue);
end;

procedure TJsonNode.SetAsString(const Value: string);
begin
  if FParent = nil then
    Error(SRootNodeKind);
  if FKind <> nkString then
  begin
    Clear;
    FKind := nkString;
  end;
  FValue := JsonStringEncode(Value);
end;

function TJsonNode.GetAsNumber: Double;
begin
  if FParent = nil then
    Error(SRootNodeKind);
  if FKind <> nkNumber then
  begin
    Clear;
    FKind := nkNumber;
    FValue := '0';
    Result:=0; Exit;
  end;
  Result := StrToFloatDef(FValue, 0);
end;

procedure TJsonNode.SetAsNumber(Value: Double);
begin
  if FParent = nil then
    Error(SRootNodeKind);
  if FKind <> nkNumber then
  begin
    Clear;
    FKind := nkNumber;
  end;
  FValue := FloatToStr(Value);
end;

function TJsonNode.Add(Kind: TJsonNodeKind; const Name, Value: string): TJsonNode;
var
  S: string;
begin
  if not (FKind in [nkArray, nkObject]) then
    if Name = '' then
      AsArray
    else
      AsObject;
  if FKind in [nkArray, nkObject] then
  begin
    if FList = nil then
      FList := TList.Create;
    if FKind = nkArray then
      S := IntToStr(FList.Count)
    else
      S := Name;
    Result := Child(S);
    if Result = nil then
    begin
      Result := TJsonNode.Create;
      Result.FName := S;
      FList.Add(Result);
    end;
    if Kind = nkNull then
      Result.FValue := 'null'
    else if Kind in [nkBool, nkString, nkNumber] then
      Result.FValue := Value
    else
    begin
      Result.FValue := '';
      Result.Clear;
    end;
    Result.FParent := Self;
    Result.FKind := Kind;
  end
  else
    Error(SNodeNotCollection);
end;

function TJsonNode.Add(const Name: string; K: TJsonNodeKind = nkObject): TJsonNode; 
begin
  case K of
    nkObject, nkArray: Result := Add(K, Name, '');
    nkNull: Result := Add(K, Name, 'null');
    nkBool: Result := Add(K, Name, 'false');
    nkNumber: Result := Add(K, Name, '0');
    nkString: Result := Add(K, Name, '""');
  end;
end;

function TJsonNode.Add(const Name: string; B: Boolean): TJsonNode;
const
  Bools: array[Boolean] of string = ('false', 'true');
begin
  Result := Add(nkBool, Name, Bools[B]);
end;

function TJsonNode.Add(const Name: string; const N: Double): TJsonNode;
begin
  Result := Add(nkNumber, Name, FloatToStr(N));
end;

function TJsonNode.Add(const Name: string; const S: string): TJsonNode;
begin
  Result := Add(nkString, Name, JsonStringEncode(S));
end;

procedure TJsonNode.Delete(Index: Integer);
var
  N: TJsonNode;
begin
  N := Child(Index);
  if N <> nil then
  begin
    FList.Delete(Index);
    if FList.Count = 0 then
    begin
      FList.Free;
      FList := nil;
    end;
  end;
end;

procedure TJsonNode.Delete(const Name: string);
var
  N: TJsonNode;
begin
  N := Child(Name);
  if N <> nil then
  begin
    FList.Remove(N);
    if FList.Count = 0 then
    begin
      FList.Free;
      FList := nil;
    end;
  end;
end;

procedure TJsonNode.Clear;
var
  I: Integer;
begin
  if FList <> nil then
  begin
    for I := 0 to FList.Count - 1 do
      TObject(FList[I]).Free;
    FList.Free;
    FList := nil;
  end;
end;

function TJsonNode.Child(Index: Integer): TJsonNode;
begin
  if FKind in [nkArray, nkObject] then
  begin
    if FList = nil then
      Error(SIndexOutOfBounds);
    if (Index < 0) or (Index > FList.Count - 1) then
      Error(SIndexOutOfBounds);
    Result := TJsonNode(FList[Index]);
  end
  else
    Error(SNodeNotCollection);
end;

function TJsonNode.Child(const Name: string): TJsonNode;
var
  N: TJsonNode;
  I: Integer;
begin
  Result := nil;
  if (FList <> nil) and (FKind in [nkArray, nkObject]) then
    if FKind = nkArray then
    begin
      I := StrToIntDef(Name, -1);
      if (I > -1) and (I < FList.Count) then begin
        Result:=(TJsonNode(FList[I]));Exit;
      end;
    end
    else for I := 0 to FList.Count - 1 do
    begin
      N := TJsonNode(FList[I]);
      if N.FName = Name then begin
        Result:=(N);Exit;
      end;
    end;
end;

function TJsonNode.Find(const Path: string): TJsonNode;
var
  N: TJsonNode;
  A, B: PChar;
  S: string;
begin
  Result := nil;
  if Path = '' then begin
    Result:= (Child(''));Exit;
  end;
  if Path[1] = '/' then
  begin
    N := Self;
    while N.Parent <> nil do
      N := N.Parent;
  end
  else
    N := Self;
  A := PChar(Path);
  if A^ = '/' then
  begin
    Inc(A);
    if A^ = #0 then begin
      Result:=(N);Exit;
    end;
  end;
  if A^ = #0 then begin
    Result:=(N.Child(''));Exit;
  end;
  B := A;
  while B^ > #0 do
  begin
    if B^ = '/' then
    begin
      SetString(S, A, B - A);
      N := N.Child(S);
      if N = nil then begin
        Result:=(nil);Exit;
      end;
      A := B + 1;
      B := A;
    end
    else
    begin
      Inc(B);
      if B^ = #0 then
      begin
        SetString(S, A, B - A);
        N := N.Child(S);
      end;
    end;
  end;
  Result := N;
end;

function TJsonNode.Format(const Indent: string): string;

  function EnumNodes: string;
  var
    I, J: Integer;
    S: string;
  begin
    if (FList = nil) or (FList.Count = 0) then begin
      Result:=(' ');Exit;
    end;
    Result := #10;
    J := FList.Count - 1;
    S := Indent + #9;
    for I := 0 to J do
    begin
      Result := Result + TJsonNode(FList[I]).Format(S);
      if I < J then
        Result := Result + ','#10
      else
        Result := Result + #10 + Indent;
    end;
  end;

var
  Prefix: string;
begin
  Result := '';
  if (FParent <> nil) and (FParent.FKind = nkObject) then
    Prefix := JsonStringEncode(FName) + ': '
  else
    Prefix := '';
  case FKind of
    nkObject: Result := Indent + Prefix +'{' + EnumNodes + '}';
    nkArray: Result := Indent + Prefix + '[' + EnumNodes + ']';
  else
    Result := Indent + Prefix + FValue;
  end;
end;

function TJsonNode.FormatCompact: string;

  function EnumNodes: string;
  var
    I, J: Integer;
  begin
    Result := '';
    if (FList = nil) or (FList.Count = 0) then
      Exit;
    J := FList.Count - 1;
    for I := 0 to J do
    begin
      Result := Result + TJsonNode(FList[I]).FormatCompact;
      if I < J then
        Result := Result + ',';
    end;
  end;

var
  Prefix: string;
begin
  Result := '';
  if (FParent <> nil) and (FParent.FKind = nkObject) then
    Prefix := JsonStringEncode(FName) + ':'
  else
    Prefix := '';
  case FKind of
    nkObject: Result := Prefix + '{' + EnumNodes + '}';
    nkArray: Result := Prefix + '[' + EnumNodes + ']';
  else
    Result := Prefix + FValue;
  end;
end;

function TJsonNode.ToString: string;
begin
  Result := Format('');
end;

function TJsonNode.GetCount: Integer;
begin
  if FList <> nil then
    Result := FList.Count
  else
    Result := 0;
end;

{ Json helper routines }

function JsonValidate(const Json: string): Boolean;
var
  N: TJsonNode;
begin
  N := TJsonNode.Create;
  try
    Result := N.TryParse(Json);
  finally
    N.Free;
  end;
end;

function JsonNumberValidate(const N: string): Boolean;
var
  C: PChar;
  T: TJsonToken;
begin
  C := PChar(N);
  Result := NextToken(C, T) and (T.Kind = tkNumber) and (T.Value = N);
end;

function JsonStringValidate(const S: string): Boolean;
var
  C: PChar;
  T: TJsonToken;
begin
  C := PChar(S);
  Result := NextToken(C, T) and (T.Kind = tkString) and (T.Value = S);
end;

{ Convert a pascal string to a json string }

function JsonStringEncode(const S: string): string;

  function Len(C: PChar): Integer;
  var
    I: Integer;
  begin
    I := 0;
    while C^ > #0 do
    begin
      if C^ < ' ' then
        if C^ in [#8..#13] then
          Inc(I, 2)
        else
          Inc(I, 6)
      else if C^ in ['"', '\'] then
        Inc(I, 2)
      else
        Inc(I);
      Inc(C);
    end;
    Result := I + 2;
  end;

const
  EscapeChars: PChar = '01234567btnvfr';
  HexChars: PChar = '0123456789ABCDEF';
var
  C: PChar;
  R: string;
  I: Integer;
begin
  if S = '' then begin
    Result:=('""');Exit;
  end;
  C := PChar(S);
  R := '';
  SetLength(R, Len(C));
  R[1] := '"';
  I := 2;
  while C^ > #0 do
  begin
    if C^ < ' ' then
    begin
      R[I] := '\';
      Inc(I);
      if C^ in [#8..#13] then
        R[I] := EscapeChars[Ord(C^)]
      else
      begin
        R[I] := 'u';
        R[I + 1] := '0';
        R[I + 2] := '0';
        R[I + 3] := HexChars[Ord(C^) div $10];
        R[I + 4] := HexChars[Ord(C^) mod $10];
        Inc(I, 4);
      end;
    end
    else if C^ in ['"', '\'] then
    begin
      R[I] := '\';
      Inc(I);
      R[I] := C^;
    end
    else
      R[I] := C^;
    Inc(I);
    Inc(C);
  end;
  R[Length(R)] := '"';
  Result := R;
end;

{ Convert a json string to a pascal string }

function UnicodeToString(C: LongWord): string;
begin
  if C = 0 then
    Result := #0
  else if C < $80 then
    Result := Chr(C)
  else if C < $800 then
    Result := Chr((C shr $6) + $C0) + Chr((C and $3F) + $80)
  else if C < $10000 then
    Result := Chr((C shr $C) + $E0) + Chr(((C shr $6) and
      $3F) + $80) + Chr((C and $3F) + $80)
  else if C < $200000 then
    Result := Chr((C shr $12) + $F0) + Chr(((C shr $C) and
      $3F) + $80) + Chr(((C shr $6) and $3F) + $80) +
      Chr((C and $3F) + $80)
  else
    Result := '';
end;

function UnicodeToSize(C: LongWord): Integer;
begin
  if C = 0 then
    Result := 1
  else if C < $80 then
    Result := 1
  else if C < $800 then
    Result := 2
  else if C < $10000 then
    Result := 3
  else if C < $200000 then
    Result := 4
  else
    Result := 0;
end;

function HexToByte(C: Char): Byte;
const
  Zero = Ord('0');
  UpA = Ord('A');
  LoA = Ord('a');
begin
  if C < 'A' then
    Result := Ord(C) - Zero
  else if C < 'a' then
    Result := Ord(C) - UpA + 10
  else
    Result := Ord(C) - LoA + 10;
end;

function HexToInt(A, B, C, D: Char): Integer;
begin
  Result := HexToByte(A) shl 12 or HexToByte(B) shl 8 or HexToByte(C) shl 4 or
    HexToByte(D);
end;

function JsonStringDecode(const S: string): string;

  function Len(C: PChar): Integer;
  var
    I, J: Integer;
  begin
    if C^ <> '"'  then begin
      Result:=0; Exit;
    end;
    Inc(C);
    I := 0;
    while C^ <> '"' do
    begin
      if C^ = #0 then begin
        Result:=0; Exit;
      end;
      if C^ = '\' then
      begin
        Inc(C);
        if C^ = 'u' then
        begin
          if (C[1] in Hex) and (C[2] in Hex) and (C[3] in Hex) and (C[4] in Hex) then
          begin
            J := UnicodeToSize(HexToInt(C[1], C[2], C[3], C[4]));
            if J = 0 then begin
              Result:=0; Exit;
            end;
            Inc(I, J - 1);
            Inc(C, 4);
          end
          else begin
            Result:=0; Exit;
          end;
        end
        else if C^ = #0 then begin
          Result:=0; Exit;
        end;
      end;
      Inc(C);
      Inc(I);
    end;
    Result := I;
  end;

const
  Escape = ['b', 't', 'n', 'v', 'f', 'r'];
var
  C: PChar;
  R: string;
  I, J: Integer;
  H: string;
begin
  C := PChar(S);
  I := Len(C); //Len(C) daba 0
  if I < 1 then begin
    Result:=('');Exit;
  end;
  R := '';
  SetLength(R, I);
  I := 1;
  Inc(C);
  while C^ <> '"' do
  begin
    if C^ = '\' then
    begin
      Inc(C);
      if C^ in Escape then
      case C^ of
        'b': R[I] := #8;
        't': R[I] := #9;
        'n': R[I] := #10;
        'v': R[I] := #11;
        'f': R[I] := #12;
        'r': R[I] := #13;
      end
      else if C^ = 'u' then
      begin
        H := UnicodeToString(HexToInt(C[1], C[2], C[3], C[4]));
        for J := 1 to Length(H) - 1 do
        begin
          R[I] := H[J];
          Inc(I);
        end;
        R[I] := H[Length(H)];
        Inc(C, 4);
      end
      else
        R[I] := C^;
    end
    else
      R[I] := C^;
    Inc(C);
    Inc(I);
  end;
  Result := R;
end;

function JsonToXml(const S: string): string;
const
  Kinds: array[TJsonNodeKind] of string =
    (' kind="object"', ' kind="array"', ' kind="bool"', ' kind="null"', ' kind="number"', '');
  Space = '    ';

  function Escape(N: TJsonNode): string;
  begin
    Result := N.Value;
    if N.Kind = nkString then
    begin
      Result := JsonStringDecode(Result);
      Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
      Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
    end;
  end;

  function EnumNodes(P: TJsonNode; const Indent: string): string;
  var
    N: TJsonNode;
    Enum: TJsonNodeEnumerator;
    S: string;
  begin
    Result := '';
    if P.Kind = nkArray then
      S := 'item'
    else
      S := '';
    Enum:= P.GetEnumerator;
    N:= Enum.GetCurrent;
    while Enum.MoveNext do
//    for N in P do
    begin
      Result := Result + Indent + '<' + S + N.Name + Kinds[N.Kind];
      case N.Kind of
        nkObject, nkArray:
          if N.Count > 0 then
            Result := Result +  '>'#10 + EnumNodes(N, Indent + Space) +
              Indent + '</' + S + N.Name + '>'#10
          else
            Result := Result + '/>'#10;
        nkNull: Result := Result + '/>'#10;
      else
        Result := Result + '>' + Escape(N) + '</' +  S + N.Name + '>'#10;
      end;

      N:= Enum.GetCurrent;
    end;
  end;

var
  N: TJsonNode;
begin
  Result := '';
  N := TJsonNode.Create;
  try
    if N.TryParse(S) then
    begin
      Result :=
        '<?xml version="1.0" encoding="UTF-8"?>'#10 +
        '<root' +  Kinds[N.Kind];
        if N.Count > 0 then
          Result := Result +  '>'#10 + EnumNodes(N, Space) + '</root>'
        else
          Result := Result + '/>';
    end;
  finally
    N.Free;
  end;
end;

end.
