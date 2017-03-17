detDetonateRope = {
  private ["_veh"];
  _rope = _this ;
  while { ropeLength _rope > 15} do
    {
        _ends = ropeEndPosition _rope;
      _temp = "DemoCharge_Remote_Ammo"  createVehicle (_ends select 1);
      _temp setDamage 1;
        ropeCut [_rope,ropeLength _rope-1];
        sleep 0.0002;
    };
    ropeDestroy _rope;
};

detGenRope = {
  private ["_veh"];
  _veh  = _this;
  _bag = "Land_RotorCoversBag_01_F" createVehicle [0,0,0];
  _rope =  ropeCreate [_veh, [0,-1.7,-1], (_veh getVariable ["det_length",45])];
  _bag attachTo [_veh,[0,-1.7,0]];
  _bag setVectorDirAndUp [[0,-0.5,-0.5],[0,0.5,-0.5]];
  [_bag,[0,0,0],[0,0,-1]] ropeAttachTo _rope;
  sleep 3;
  detach _bag;
  _source01 = "#particlesource" createVehicle [0,0,0];
  _source01 setParticleClass "missile1";
  _bag setVelocityModelSpace [0,0,-30];
  playSound3D ["A3\Sounds_F\weapons\Rockets\missile_1.wss", _veh];
  _source01 attachTo [_bag,[0,0,1]];
   sleep 2;
   deleteVehicle _source01;
  _veh setVariable ["det_rope", _rope, true];
  _veh setUserActionText [(_veh getVariable "det_act") , "Detonate"];
};

detAct = {
  private ["_veh"];
  _veh = _this;
  if(isNull (_veh getVariable "det_rope")) then {
    _veh spawn detGenRope;
  } else {
    (_veh getVariable "det_rope") spawn detDetonateRope;
    _veh setVariable ["det_rope", objNull, true];
    _ammo = ((_veh getVariable "det_ammo")-1);
    _veh setVariable ["det_ammo", _ammo , true];
    if(_ammo < 1) then {
      _veh removeAction  (_veh getVariable "det_act");
    } else {
      _veh setUserActionText [(_veh getVariable "det_act") , "Launch DetCord"];
    };
  };
};

detInit = {
  private ["_veh"];
  _veh = (_this select 0);
  _act =  _veh addAction ["Launch DetCord", {(_this select 0) spawn detAct;}];
  _veh setVariable ["det_act", _act, true];
  _veh setVariable ["det_rope", objNull, true];
  _veh setVariable ["det_ammo", (_this select 1), true];
  _veh setVariable ["det_length", (_this select 2), true];
};
[car,2,80] spawn detInit;
