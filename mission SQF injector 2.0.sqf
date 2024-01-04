comment "Determine if execution context is composition and delete the helipad.";  
if ((!isNull (findDisplay 312)) && (!isNil 'this')) then { 
 if (!isNull this) then {  
  if (typeOf this == 'Land_HelipadEmpty_F') then {  
   deleteVehicle this;  
  };  
 };  
}; 
0 = [] spawn { 
	waitUntil {isNull findDisplay 49}; 

	private _initREpack = [] spawn { 
	if (!isNil 'M9SD_fnc_RE2_V3') exitWith {}; 
	comment "Initialize Remote-Execution Package"; 
	M9SD_fnc_initRE2_V3 = { 
	M9SD_fnc_initRE2Functions_V3 = { 
	comment "Prep RE2 functions."; 
	M9SD_fnc_REinit2_V3 = { 
		private _functionNameRE2 = ''; 
		if (isNil {_this}) exitWith {false}; 
		if !(_this isEqualType []) exitWith {false}; 
		if (count _this == 0) exitWith {false}; 
		private _functionNames = _this; 
		private _aString = ""; 
		private _namespaces = [missionNamespace, uiNamespace]; 
		{ 
		if !(_x isEqualType _aString) then {continue}; 
		private _functionName = _x; 
		_functionNameRE2 = format ["RE2_%1", _functionName]; 
		{ 
		private _namespace = _x; 
		with _namespace do { 
		if (!isNil _functionName) then { 
			private _fnc = _namespace getVariable [_functionName, {}]; 
			private _fncStr = str _fnc; 
			private _fncStr2 = "{" +  
			"removeMissionEventHandler ['EachFrame', _thisEventHandler];" +  
			"_thisArgs call " + _fncStr +  
			"}"; 
			private _fncStrArr = _fncStr2 splitString ''; 
			_fncStrArr deleteAt (count _fncStrArr - 1); 
			_fncStrArr deleteAt 0; 
			_namespace setVariable [_functionNameRE2, _fncStrArr, true]; 
		}; 
		}; 
		} forEach _namespaces; 
		} forEach _functionNames; 
		true;_functionNameRE2; 
	}; 
	M9SD_fnc_RE2_V3 = { 
		params [["_REarguments", []], ["_REfncName2", ""], ["_REtarget", player], ["_JIPparam", false]]; 
		if (!((missionnamespace getVariable [_REfncName2, []]) isEqualType []) && !((uiNamespace getVariable [_REfncName2, []]) isEqualType [])) exitWith { 
		systemChat "::Error:: remoteExec failed (invalid _REfncName2 - not an array)."; 
		}; 
		if ((count (missionnamespace getVariable [_REfncName2, []]) == 0) && (count (uiNamespace getVariable [_REfncName2, []]) == 0)) exitWith { 
		systemChat "::Error:: remoteExec failed (invalid _REfncName2 - empty array)."; 
		systemChat str _REfncName2; 
		}; 
		[[_REfncName2, _REarguments],{  
		addMissionEventHandler ["EachFrame", (missionNamespace getVariable [_this # 0, ['']]) joinString '', _this # 1];  
		}] remoteExec ['call', _REtarget, _JIPparam]; 
	}; 
	comment "systemChat '[ RE2 Package ] : RE2 functions initialized.';"; 
	}; 
	M9SD_fnc_initRE2FunctionsGlobal_V2 = { 
	comment "Prep RE2 functions on all clients+jip."; 
	private _fncStr = format ["{ 
		removeMissionEventHandler ['EachFrame', _thisEventHandler]; 
		_thisArgs call %1 
	}", M9SD_fnc_initRE2Functions_V3]; 
	_fncStr = _fncStr splitString ''; 
	_fncStr deleteAt (count _fncStr - 1); 
	_fncStr deleteAt 0; 
	missionNamespace setVariable ["RE2_M9SD_fnc_initRE2Functions_V2", _fncStr, true]; 
	[["RE2_M9SD_fnc_initRE2Functions_V2", []],{  
		addMissionEventHandler ["EachFrame", (missionNamespace getVariable ["RE2_M9SD_fnc_initRE2Functions_V2", ['']]) joinString '', _this # 1];  
	}] remoteExec ['call', 0, 'RE2_M9SD_JIP_initRE2Functions_V2']; 
	comment "Delete from jip queue: remoteExec ['', 'RE2_M9SD_JIP_initRE2Functions_V2'];"; 
	}; 
	call M9SD_fnc_initRE2FunctionsGlobal_V2; 
	}; 
	call M9SD_fnc_initRE2_V3; 
	waitUntil {!isNil 'M9SD_fnc_RE2_V3'}; 
	if (true) exitWith {true}; 
	}; 
	waitUntil {scriptDone _initREpack}; 
	waitUntil {!isNil 'M9SD_fnc_REinit2_V3'}; 
	M9SD_fnc_commentCompatability = 
	{ 
		_input = _this select 0;
		private _strings = [];
		private _start = -1;
		while {_start = _input find "//"; _start > -1} do 
		{	
			_input select [0, _start] call
			{
				private _badQuotes = _this call 
				{
					private _qtsGood = [];
					private _qtsInfo = [];
					private _arr = toArray _this;
					{
						_qtsGood pushBack ((count _arr - count (_arr - [_x])) % 2 == 0);
						_qtsInfo pushBack [_this find toString [_x], _x];
					} 
					forEach [34, 39];
					if (_qtsGood isEqualTo [true, true]) exitWith {0};
					_qtsInfo sort true;
					_qtsInfo select 0 select 1
				};
				if (_badQuotes > 0) exitWith
				{ 
					_last = _input select [_start] find toString [_badQuotes];
					if (_last < 0) exitWith 
					{
						_strings = [_input];
						_input = "";
					};
					_last = _start + _last + 1;
					_strings pushBack (_input select [0, _last]);
					_input = _input select [_last];
				};
				_strings pushBack _this;
				_input = _input select [_start];
				private _end = _input find toString [10];
				if (_end < 0) exitWith {_input = ""};
				_input = _input select [_end + 1];
			};
		};
		_input = (_strings joinString "") + _input;
		_input
	};
	M9SD_fnc_executeMissionSQF = 
	{
		params [['_execType', 'default'], ['_codeText', '[] call {};'], ['_targetObject', objNull]];
		profileNamespace setVariable ['M9SD_previousSQF_injection', _codeText];
		saveProfileNamespace;	
		_codeText = [_codeText] call M9SD_fnc_commentCompatability;
		switch (toLower _execType) do 
		{
			case 'server': {
				comment 'server execute';
				systemChat 'Sending script to server...';
				_code = compile _codeText; 
				M9SD_fnc_sqfInj_serverExec = _code; 
				[[], (['M9SD_fnc_sqfInj_serverExec'] call M9SD_fnc_REinit2_V3), 2] call M9SD_fnc_RE2_V3; 
				showChat true;
				playSound 'addItemOK';
			};
			default 
			{
				comment 'local';
				_codeText spawn
				{
					_fnc = compile _this;
					_script = [] spawn _fnc;
					waitUntil {scriptDone _script};
					systemChat 'Script executed.';

				};
			};
		};
	};
	M9SD_fnc_openMissionInjector = 
	{
		findDisplay 49 closeDisplay 0;
		disableSerialization;
		with uiNamespace do 
		{
			createDialog 'RscDisplayEmpty';
			showChat true;
			private _d = findDisplay -1;
			private _bkCtrl_01 = _d ctrlCreate ['IGUIBack',-1];
			_bkCtrl_01 ctrlSetPosition [0.298907 * safezoneW + safezoneX,0.236 * safezoneH + safezoneY,0.402187 * safezoneW,0.528 * safezoneH];
			_bkCtrl_01 ctrlSetBackgroundColor [0,0.0,0,0.9];
			_bkCtrl_01 ctrlCommit 0;
			private _bkCtrl_02 = _d ctrlCreate ['RscFrame',-1];
			_bkCtrl_02 ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.236 * safezoneH + safezoneY,0.391875 * safezoneW,0.473 * safezoneH];
			_bkCtrl_02 ctrlSetText 'Execute SQF';
			_bkCtrl_02 ctrlSetTextColor [0,1,0,1];
			_bkCtrl_02 ctrlCommit 0;
			private _bkCtrlcode = _d ctrlCreate ['RscEditMulti',-1];
			_bkCtrlcode ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.247 * safezoneH + safezoneY,0.391875 * safezoneW,0.462 * safezoneH];
			_bkCtrlcode ctrlSetTooltip '';
			_bkCtrlcode ctrlSetTextColor [0,1,0,1];
			_bkCtrlcode ctrlSetText (profileNamespace getVariable ['M9SD_previousSQF_injection', '']);
			_bkCtrlcode ctrlCommit 0;
			_d setVariable ['code', _bkCtrlcode];

			private _btnCtrl_03 = _d ctrlCreate ['RscButtonMenu',-1];
			_btnCtrl_03 ctrlSetTooltip 'Execute script on local client (your computer).';
			_btnCtrl_03 ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.6)) + "'><img image='\A3\3den\data\Displays\Display3den\toolbar\widget_local_ca.paa'></img> LOCAL</t>");
			_btnCtrl_03 ctrlSetPosition [0.608281 * safezoneW + safezoneX,0.72 * safezoneH + safezoneY,0.0876563 * safezoneW,0.033 * safezoneH];
			_btnCtrl_03 ctrlAddEventHandler ['ButtonClick', 
			{
				params ["_control"];
				_parentDisplay = ctrlParent _control;
				_ctrlCode = _parentDisplay getVariable 'code';
				_codeText = ctrlText _ctrlCode;
				this = missionNamespace getVariable ['M9SD_objNull', objNull];
				['local', _codeText, this] call M9SD_fnc_executeMissionSQF;
				_parentDisplay closeDisplay 0;
				_feedbackText = format ["Executing script (local)..."];
				systemChat _feedbackText;
				_zeusLogic = objNull;
				_zeusLogic = getAssignedCuratorLogic player;
				if (isNull _zeusLogic) exitWith {};
				[_zeusLogic, _feedbackText] call BIS_fnc_showCuratorFeedbackMessage;
			}];
			_btnCtrl_03 ctrlSetBackgroundColor [0.1,0.1,0.3,0.6];
			_btnCtrl_03 ctrlCommit 0;

			private _btnCtrl_99 = _d ctrlCreate ['RscButtonMenu',-1];
			_btnCtrl_99 ctrlSetTooltip 'Execute script on server machine.';
			_btnCtrl_99 ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.6)) + "'><img image='\a3\3den\data\displays\display3den\statusbar\server_ca.paa'></img> SERVER</t>");
			_btnCtrl_99 ctrlSetPosition [0.515469 * safezoneW + safezoneX,0.72 * safezoneH + safezoneY,0.0876563 * safezoneW,0.033 * safezoneH];
			_btnCtrl_99 ctrlAddEventHandler ['ButtonClick', 
			{
				params ["_control"];
				_parentDisplay = ctrlParent _control;
				_ctrlCode = _parentDisplay getVariable 'code';
				_codeText = ctrlText _ctrlCode;
				this = missionNamespace getVariable ['M9SD_objNull', objNull];
				['server', _codeText, this] call M9SD_fnc_executeMissionSQF;
				_parentDisplay closeDisplay 0;
				_feedbackText = format ["Executing script (server)..."];
				systemChat _feedbackText;
				_zeusLogic = objNull;
				_zeusLogic = getAssignedCuratorLogic player;
				if (isNull _zeusLogic) exitWith {};
				[_zeusLogic, _feedbackText] call BIS_fnc_showCuratorFeedbackMessage;
			}];
			_btnCtrl_99 ctrlSetBackgroundColor [0.1,0.3,0.1,0.6];
			_btnCtrl_99 ctrlCommit 0;

			private _btnCtrl_06 = _d ctrlCreate ['RscButtonMenu',-1];
			_btnCtrl_06 ctrlSetTooltip 'Close menu.';
			_btnCtrl_06 ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.6)) + "'><img image='\a3\ui_f_curator\data\CfgCurator\waypoint_ca.paa'></img> CANCEL</t>");
			_btnCtrl_06 ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.72 * safezoneH + safezoneY,0.0876563 * safezoneW,0.033 * safezoneH];
			_btnCtrl_06 ctrlAddEventHandler ['ButtonClick', 
			{
				params ["_control"];
				_parentDisplay = ctrlParent _control;
				_parentDisplay closeDisplay 0;
			}];
			_btnCtrl_06 ctrlSetBackgroundColor [0.2,0.2,0.2,0.5];
			_btnCtrl_06 ctrlCommit 0;
		};
	};
	[] spawn M9SD_fnc_openMissionInjector;
};