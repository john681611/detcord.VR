/*How To use : Execute script with execVM
 Initalisation of vehicle = [vehicle,ammo(number),(rope lenth)] spawn detInit;
*/

detConfig = [
//[[Vehicle('s')],ropeattpoint,baglaunchpoint,vectors]
  ["LSV_01_base_F",[0,-1.7,-1],[0,-1.7,0], [[0,-0.5,-0.5],[0,0.5,-0.5]]],
  ["APC_Tracked_01_base_F",[-0.5,-2.1,-0.1],[-0.5,-2.1,0.1],[[0,-0.5,0.75],[0,-0.75,-0.5]]],

  //3CB
  ["UK3CB_BAF_LandRover_Soft_Base",[0,-2.2,-1.1],[0,-2.4,-0.2], [[0,-0.5,-0.5],[0,0.5,-0.5]]]

];

detFindVehConfig = {
  _return = ["FAIL"];
  {
    if(_this isKindOf (_x select 0)) exitWith {
    _return = _x;
    };
  } forEach detConfig;
    _return
};

detDetonateRope = {
  private ["_rope"];
  _rope = _this ;
  while { ropeLength _rope > 20} do
    {
        _ends = ropeEndPosition _rope;
      _temp = "DemoCharge_Remote_Ammo"  createVehicle (_ends select 1);
      _temp setDamage 1;
        ropeCut [_rope,ropeLength _rope-10];
        sleep 0.0002;
    };
    sleep 15;
    ropeDestroy _rope;
};

detCutRope = {
  private ["_veh","_rope"];
};

detGenRope = {
  private ["_veh"];

  _veh  = _this;
  _pos = _veh call detFindVehConfig;
  if((_pos select 0) =="FAIL") exitWith {"Missing Vehicle Config" remoteExec ["hint"];};
  _rope =  ropeCreate [_veh, (_pos select 1), (_veh getVariable "det_length")+20];
  _veh setVariable ["det_rope", _rope, true];
  _veh remoteExec ["detUpdateTextDetonate",0,true];
  _bag = "Land_RotorCoversBag_01_F" createVehicle [0,0,0];
  _chem = "Chemlight_red" createVehicle [0,0,0];
  _chem attachTo [_bag,[0,0,0]];
  _bag attachTo [_veh,(_pos select 2)];
  _bag setVectorDirAndUp (_pos select 3);
  sleep 2;
  [_bag,[0,0,0],[0,0,-1]] ropeAttachTo _rope;
  _light = "#lightpoint" createVehicle [0,0,0];
  [_light,_bag]  remoteExec ["detLight",0,true];
  _source01 = "#particlesource" createVehicle [0,0,0];
  _source01 setParticleClass "missile1";
  _source01 attachTo [_bag,[0,0,0.5]];
  sleep 1;
  detach _bag;
  _bag setVelocityModelSpace [0,0,-30];
  playSound3D ["A3\Sounds_F\weapons\Rockets\missile_1.wss", _veh];
   sleep 2;
   deleteVehicle _source01;
   deleteVehicle _light;
};

detAct = {
  private ["_veh"];
  _veh = _this;
  if(isNull (_veh getVariable "det_rope")) then {
    _result = ["Launch Rocket?", "Confirm", true, true] call BIS_fnc_guiMessage;
    if(_result) then {
      _veh  remoteExec ["detGenRope",2];
    };
  } else {
    _choise = ["Detonate (check 20m safty is out) or Cut Line?.","Control Panel", "Detonate", "Cut Line"] call BIS_fnc_guiMessage;
    _result = ["Are you Sure?", "Yes", true, true] call BIS_fnc_guiMessage;
    if(_result) then {
      if(_choise) then {
        (_veh getVariable "det_rope") remoteExec ["detDetonateRope", 2];
      } else {
        ropeDestroy (_veh getVariable "det_rope");
      };
      _veh setVariable ["det_rope", objNull, true];
      _ammo = ((_veh getVariable "det_ammo")-1);
      _veh setVariable ["det_ammo", _ammo , true];
      if(_ammo < 1) then {
        _veh remoteExec ["detRemoveAction", 0, true]
      } else {
        _veh  remoteExec ["detUpdateTextLaunch",0,true];
      };
    };
  };
};

detLight = {
  _light  = _this select 0;
  _bag = _this select 1;
  _light setLightBrightness 0.8;
  _light setLightAmbient [0.9,0.9,0.6];
  _light setLightColor [0.9,0.9,0.6];
  _light lightAttachObject [_bag, [0,0,0.5]];
};

detUpdateTextLaunch = {
  private ["_veh"];
  _veh = _this;
  _veh setUserActionText [(_veh getVariable "det_act") , "Launch Mine Clearance Rocket"];
};

detUpdateTextDetonate = {
  private ["_veh"];
  _veh = _this;
  _veh setUserActionText [(_veh getVariable "det_act") , "Open Rope Control Panel"];
};

detRemoveAction = {
  _this removeAction  (_this getVariable "det_act");
};

detInit = {
  private ["_veh"];
  _veh = (_this select 0);
  _act =  _veh addAction ["Launch Mine Clearance Rocket", {(_this select 0) spawn detAct;}];
  _veh setVariable ["det_act", _act, false];
  if(isNil {player getVariable "det_rope"}) then {
    _veh setVariable ["det_rope", objNull, true];
    _veh setVariable ["det_ammo", (_this select 1), true];
    _veh setVariable ["det_length", (_this select 2), true];
  };
};
