deleteVehicle this;
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
		default 
		{
			comment 'local';
			_codeText spawn
			{
				_fnc = compile _this;
				_script = [] spawn _fnc;
				waitUntil {scriptDone _script};
				systemChat 'Script executed.';
				showChat true;
				playSound 'addItemOK';
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