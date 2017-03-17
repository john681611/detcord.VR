DetonateRope = {
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

genRope = {
  _veh  = _this;
  _bag = "Land_RotorCoversBag_01_F" createVehicle [0,0,0];
  _rope =  ropeCreate [_veh, [0,-1.7,-1], 700];
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
  _veh setVariable ["ropedep", _rope, true];
  _veh setUserActionText [(_veh getVariable "ropeact") , "Detonate"];
};

ropeact = {
  _veh = _this;
  if(isNull (_veh getVariable "ropedep")) then {
    _veh spawn genRope;
  } else {
    (_veh getVariable "ropedep") spawn DetonateRope;
    _veh setVariable ["ropedep", objNull, true];
    _veh removeAction  (_veh getVariable "ropeact");
  };
};
_act =  car addAction ["Launch DetCord", {(_this select 0) spawn ropeact;}];
car setVariable ["ropeact", _act, true];
  car setVariable ["ropedep", objNull, true];
