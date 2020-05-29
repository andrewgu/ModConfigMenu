//-----------------------------------------------------------
//	Interface:	MCM_Builder_Interface
//	Author: Musashi
//	
//-----------------------------------------------------------


interface MCM_Builder_Interface;

static public function MCM_Builder_Interface GetMCMBuilder(string InstanceName);

public function array<string> GetConfig();

public function string GetBuilderName();

public function string LocalizeItem(string Key);

public function SerializeAndSaveBuilderConfig();

public function SerializeConfig();
