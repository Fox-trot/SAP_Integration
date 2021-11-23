Procedure SheduledJob_PerformDataSyncronization() Export
	
	PerformDataSyncronization();
	
EndProcedure

Procedure PerformDataSyncronization(p01 = Undefined) Export 
	
	p02 = New Query;
	p02.SetParameter("ExchangeHost", p01);
	p02.Text = "SELECT
	           |	IntegrationSettings.ExchangeHost,
	           |	IntegrationSettings.ToArchiveTheFile,
	           |	IntegrationSettings.UploadData,
	           |	IntegrationSettings.DownloadData,
	           |	IntegrationSettings.GuarantedDelivery,
	           |	IntegrationSettings.ExchangeRulesName,
	           |	IntegrationSettings.ExchangeDirectory,
	           |	IntegrationSettings.Name,
	           |	IntegrationSettings.Off,
	           |	IntegrationSettings.ArchivePassword,
	           |	IntegrationSettings.ConnectionString,
	           |	IntegrationSettings.RulesStorage,
	           |	IntegrationSettings.FTPAdress,
	           |	IntegrationSettings.FTPPassword,
	           |	IntegrationSettings.FTPUser,
	           |	IntegrationSettings.FTPPassiveConnection,
	           |	IntegrationSettings.FTPPort,
	           |	IntegrationSettings.ExchangeProtocol
	           |FROM
	           |	InformationRegister.IntegrationSettings AS IntegrationSettings
	           |WHERE
	           |	IntegrationSettings.Off = FALSE" + ?(p01 = Undefined, "", " AND IntegrationSettings.ExchangeHost = &ExchangeHost");
	;
	p03 = p02.Execute().Choose();
	While p03.Next() Do 
		p04 = New Structure("ExchangeHost, ExchangeDirectory, RulesStorage, ToArchiveTheFile, ArchivePassword, ConnectionString, GuarantedDelivery, FTPAdress, FTPPassword, FTPUser, FTPPassiveConnection, FTPPort, ExchangeProtocol", p03.ExchangeHost, p03.ExchangeDirectory, p03.RulesStorage, p03.ToArchiveTheFile, p03.ArchivePassword, p03.ConnectionString, p03.GuarantedDelivery, p03.FTPAdress, p03.FTPPassword, p03.FTPUser, p03.FTPPassiveConnection, p03.FTPPort, p03.ExchangeProtocol);
		p05 = "";
		p04.Вставить("Отказ",Ложь);
		//p05 = New ValueTable;
		//p05.Columns.Add("Level");
		//p05.Columns.Add("Description");
		If p03.DownloadData Then
			
			PerformDataDownload(p04, p05);
			
		EndIf;
		//DimaB и Не p04.Отказ
		If p03.UploadData Then
			
			PerformDataUpload(p04, p05);
			
		EndIf;
		//CheckErrorLogDirectory(p03.LogDirectory);
		//p06 = p03.LogDirectory + "\" + String(New UUID) + ".txt";
		//WriteLogToFile(p06, p05);
		
		rMan = РегистрыСведений.IntegrationLogs.СоздатьМенеджерЗаписи();
		rMan.ExchangeHost = p03.ExchangeHost;
		rMan.Период = ТекущаяДата();
		rMan.Log = p05;
		rMan.Записать();
		
	EndDo;
	
EndProcedure

Procedure PerformDataDownload(p07, p08) Export 
   
	p09 = ExchangePlans[p07.ExchangeHost.Metadata().Name].ThisNode();
	
	p10 = p07.ExchangeHost;
	p11 = Upper(InfoBaseConnectionString());
	If p11 <> p07.ConnectionString Then
		WriteEventToLogString(p08, EventLogLevel.Error, "Exchange: [" + p10.Code + "] --> [" + p09.Code + "]" + Chars.LF + " Download" + Chars.LF + "" + CurrentDate() + " The discrepancy connection string" + Chars.LF + " --");
		Return;
	EndIf;
	
	ExchangeFileName = "Message_" + p10.Code + "_" + p09.Code + ?(p07.ToArchiveTheFile, ".zip", ".xml");
	dosyaKonumu = GetTempFileName(?(p07.ToArchiveTheFile, ".zip", ".xml"));
	
	If p07.ExchangeProtocol = 1 Then
		
		//Перем Соединение, ИмяFTPСервера, ИмяКаталогаСервера;
		FTPConn = Undefined;
		FTPServerName = Undefined;
		FTPDirectoryName = Undefined;
		FTPConnected = CheckFTPConnectionSettings(p07, p08, FTPDirectoryName, FTPServerName, FTPConn); 
		
		If Not FTPConnected Then
			Return;
		EndIf;
		
		p12 = FTPDirectoryName+ExchangeFileName;
		
		Try
			
			FTPConn.Get(p12,dosyaKonumu);
			
		Except
			
			WriteEventToLogString(p08,EventLogLevel.Error,"File can not be saved to FTP: "+p12);
			
		EndTry;
		
	Else 
		p12 = p07.ExchangeDirectory + "\" + ExchangeFileName;
		p13 = New File(p12);
		If Not p13.Exist() Then
			WriteEventToLogString(p08, EventLogLevel.Error, "Exchange: [" + p10.Code + "] --> [" + p09.Code + "]" + Chars.LF + " Download" + Chars.LF + "" + CurrentDate() + " File: <"+ExchangeFileName + "> is missing" + Chars.LF + " --");
			Return;
		EndIf;
		
		FileCopy(p12,dosyaKonumu);
		
	EndIf; 
	
	//p14 = p07.LogDirectory + "\" + String(New UUID) + ".txt";
	p14 = GetTempFileName(".txt");
	p15 = DataProcessors.UniversalDataExchangeForAsfarma_mr.Create();
	p15.РежимОбмена = "Загрузка";
	//p15.ИмяФайлаОбмена = p12;
	p15.ИмяФайлаОбмена = dosyaKonumu;
	p15.ЗаписыватьРегистрыНаборамиЗаписей = True;
	p15.ЗаписыватьВИнформационнуюБазуТолькоИзмененныеОбъекты = True;
	p15.ЗагружатьДанныеВРежимеОбмена = True;
	p15.ВыводВПротоколСообщенийОбОшибках = True;
	p15.ИмяФайлаПротоколаОбмена = p14;
	//+DimaB
	РезультирующаяСтрокаСИнформациейОбОшибке = "";
	p15.ВыполнитьЗагрузку(РезультирующаяСтрокаСИнформациейОбОшибке);
	Если Не РезультирующаяСтрокаСИнформациейОбОшибке = "" ИЛИ Не p15.Параметры.Количество() Тогда
		p07.Отказ = Истина;
		Возврат;
	КонецЕсли;
	//-DimaB
	
	LastReceivedNo = p15.Параметры.LastReceivedNumberOnDispatchHost;
	
	tReader = New TextReader(p14,TextEncoding.UTF8);
	tExchangeLogData = tReader.Read();
	tReader.Close();
	If tExchangeLogData <> Undefined Then
		WriteEventToLogString(p08,"Upload log",tExchangeLogData);
	EndIf;
	
	Попытка
	
		DeleteFiles(p14);
		DeleteFiles(p12);
		DeleteFiles(dosyaKonumu);
	
	Исключение
		WriteEventToLogString(p08, "Temp deletion", ОписаниеОшибки());
	КонецПопытки;
		
	If p07.GuarantedDelivery Then
		If Not p15.ФлагОшибки Then
			ExchangePlans.DeleteChangeRecords(p10, LastReceivedNo);
		EndIf;
	EndIf;
	
EndProcedure

Procedure PerformDataUpload(p16, p17) Export 
	
	p18 = ExchangePlans[p16.ExchangeHost.Metadata().Name].ThisNode();
	p19 = p16.ExchangeHost;
	p20 = Upper(СтрокаСоединенияИнформационнойБазы());
	If p20 <> p16.ConnectionString Then
		WriteEventToLogString(p17, EventLogLevel.Error, "Exchange: [" + p18.Code + "] --> [" + p19.Code + "]" + Chars.LF + " Upload" + Chars.LF + "" + CurrentDate() + " The discrepancy connection string" + Chars.LF + " --" + Chars.LF + "" + p20 + "" + Chars.LF + "" + p16.ConnectionString);
		Return;
	EndIf;
	
	p23 = TempFilesDir() + "ExRul_" + p18.Code + "_" + p19.Code + ".xml";
	p22 = New Файл(p23);
	If p22.Exist() Then
		DeleteFiles(p23);
	EndIf;
	Try 
		p24= p16.RulesStorage.Get();
		p24.Write(p23);
		p22 = New File(p23);
		If Not p22.Exist() Then
			WriteEventToLogString(p17, EventLogLevel.Error, "Exchange: [" + p18.Code + "] --> [" + p19.Code + "]" + Chars.LF + " Upload" + Chars.LF + "" + CurrentDate() + " Error writing file exchange rules: " + ErrorDescription() + Chars.LF + " --");
		EndIf;
	Except 
		WriteEventToLogString(p17, EventLogLevel.Error, "Exchange: [" + p18.Code + "] --> [" + p19.Code + "]" + Chars.LF + " Upload" + Chars.LF + "" + CurrentDate() + " Error writing file exchange rules: " + ErrorDescription() + Chars.LF + " --");
		Return;
	EndTry;
	
	dosyaKonumu = GetTempFileName(?(p16.ToArchiveTheFile, ".zip", ".xml"));
	
	//p26 = p16.LogDirectory + "\" + String(New UUID) + ".txt";
	p26 = GetTempFileName(".txt");
	p27 = DataProcessors.UniversalDataExchangeForAsfarma_mr.Create();
	p27.РежимОбмена = "Выгрузка";
	//Если ЗначениеЗаполнено(p16.ExchangeHost.EvrakTarihiDönemiBaşı) Тогда
	//	p27.ДатаНачала = p16.ExchangeHost.EvrakTarihiDönemiBaşı;
	//	p27.ДатаОкончания = КонецДня(p16.ExchangeHost.EvrakTarihiDönemiBaşı);
	//КонецЕсли;
	p27.ВыводВОкноСообщенийИнформационныхСообщений = False;
	p27.ИмяФайлаПравилОбмена = p23;
	//p27.ИмяФайлаОбмена = p21;
	p27.ИмяФайлаОбмена = dosyaKonumu;
	p27.АрхивироватьФайл = p16.ToArchiveTheFile;
	
	p27.ТипУдаленияРегистрацииИзмененийДляУзловОбменаПослеВыгрузки = ?(p16.GuarantedDelivery, 0, 1);
	p27.ВыводВПротоколСообщенийОбОшибках = True;
	p27.ИмяФайлаПротоколаОбмена = p26;
	If ValueIsFilled(p16.ArchivePassword) Then
		p27.ПарольДляСжатияФайлаОбмена = p16.ArchivePassword;
	EndIf;
	p27.ЗагрузитьПравилаОбмена();
	p28 = p27.ТаблицаПравилВыгрузки.Copy();
	ConfigureRulesForHost(p28, p16.ExchangeHost);
	p27.ТаблицаПравилВыгрузки = p28.Copy();
	p29 = p27.ТаблицаНастройкиПараметров.Find("GuaranteedDelivery", "Имя");
	If Not p29 = Undefined Then
		p29.Значение = p16.GuarantedDelivery;
	EndIf;
	
	p29 = p27.ТаблицаНастройкиПараметров.Find("ReceivedNo", "Имя");
	If Not p29 = Undefined Then
		p29.Значение = p16.ExchangeHost.НомерПринятого;
	EndIf;
	
    p29 = p27.ТаблицаНастройкиПараметров.Find("SentNo", "Имя");
	If Not p29 = Undefined Then
		p29.Значение = p16.ExchangeHost.НомерОтправленного+1;
	EndIf;

	
	
	
	
	
	
	p29 = p27.ТаблицаНастройкиПараметров.Найти("DispatchHost", "Имя");
	If Not p29 = Undefined Then
		p29.Значение = p18.Code;
	EndIf;
	p29 = p27.ТаблицаНастройкиПараметров.Найти("ReceiptHost", "Имя");
	If Not p29 = Undefined Then
		p29.Значение = p19.Code;
	EndIf;
	p29 = p27.ТаблицаНастройкиПараметров.Найти("USD", "Имя");
	If Not p29 = Undefined Then
		p29.Значение = Справочники.Валюты.НайтиПоНаименованию("USD");
	EndIf;
	p29 = p27.ТаблицаНастройкиПараметров.Найти("ÜlkeKodu", "Имя");
	If Not p29 = Undefined Then
		p29.Значение = "UZ";
	EndIf;
	p29 = p27.ТаблицаНастройкиПараметров.Найти("Dövizler", "Имя");
	If Not p29 = Undefined Then
		///Döviz MAP hazırlama
		_Таб = Справочники.Валюты.ПолучитьМакет("КлассификаторВалют");
		_Dövizler = Новый ТаблицаЗначений;
		_Dövizler.Колонки.Добавить("КодЛ");
		_Dövizler.Колонки.Добавить("КодУ");
		Для _Н=4 По _Таб.ВысотаТаблицы Цикл
			_кодЛ = СокрЛП(_Таб.Область("R"+_Н+"C2").Текст);
			_кодУ = СокрЛП(_Таб.Область("R"+_Н+"C3").Текст);
			Если Не ПустаяСтрока(_кодЛ) И Не ПустаяСтрока(_кодУ) Тогда
				_вСтр = _Dövizler.Добавить();
				_вСтр.КодЛ = _кодЛ;
				_вСтр.КодУ = _кодУ;
			КонецЕсли; 
		КонецЦикла; 
		p29.Значение = _Dövizler;
	EndIf;
	p27.ВыполнитьВыгрузку();
	
	tReader = New TextReader(p26,TextEncoding.UTF8);
	tExchangeLogData = tReader.Read();
	tReader.Close();
	If tExchangeLogData <> Undefined Then
		WriteEventToLogString(p17,"Upload log",tExchangeLogData);
	EndIf;
	Попытка
		DeleteFiles(p26);
	Исключение
		WriteEventToLogString(p17, "Temp deletion", ОписаниеОшибки());
	КонецПопытки;
	
	ExchangeFileName = "Message_" + p18.Code + "_" + p19.Code + ?(p16.ToArchiveTheFile, ".zip", ".xml");
	
	d = New File(dosyaKonumu);
	If d.Exist() Then
		
		If p16.ExchangeProtocol = 1 Then
			
			//Перем Соединение, ИмяFTPСервера, ИмяКаталогаСервера;
			FTPConn = Undefined;
			FTPServerName = Undefined;
			FTPDirectoryName = Undefined;
			FTPConnected = CheckFTPConnectionSettings(p16, p17, FTPDirectoryName, FTPServerName, FTPConn); 
			
			If Not FTPConnected Then
				Return;
			EndIf;
			
			p21 = FTPDirectoryName+ExchangeFileName;
			
			Try
			
				FTPConn.Put(dosyaKonumu,p21);
			
			Except
				
				WriteEventToLogString(p17,EventLogLevel.Error,"File can not be saved to FTP: "+p21);
				
			EndTry;
			
		Else 
			p21 = p16.ExchangeDirectory + "\"+ExchangeFileName;
			p22 = New File(p21);
			If p22.Exist() Then
				WriteEventToLogString(p17, EventLogLevel.Error, "Exchange: [" + p18.Code + "] --> [" + p19.Code + "]" + Chars.LF + " Upload" + Chars.LF + "" + CurrentDate() + " Data on the opposite host is not yet taken" + Chars.LF + " --");
				Return;
			EndIf;
			
			FileCopy(dosyaKonumu,p21);
			
		EndIf; 
		
		Попытка
			
			DeleteFiles(dosyaKonumu);
			
		Исключение
			WriteEventToLogString(p17, "Temp deletion", ОписаниеОшибки());
		КонецПопытки;
		
	EndIf; 
	
EndProcedure

Procedure ConfigureRulesForHost(p30, p31)
	
	p32 = p30.Строки;
	For Each p33 In p32 Do
		p34 = p33.Строки;
		For Each p35 In p34 Do
			p35.СсылкаНаУзелОбмена = p31;
			Если p33.Наименование="Документы" или p33.Наименование="РегистрыСведений" Тогда 
				p35.ИспользоватьОтбор=True;	
			КонецЕсли;	
		EndDo;
		Если p33.Наименование="Документы" или p33.Наименование="РегистрыСведений" Тогда 
			p33.ИспользоватьОтбор=True;	
		КонецЕсли;	
	EndDo;
	
EndProcedure

//Procedure CheckErrorLogDirectory(p36)
//	
//	p37 = New File(p36);
//	If Not p37.Exist() Then
//		CreateDirectory(p36);
//	EndIf;
//	
//EndProcedure

Procedure WriteEventToLogString(p38, p39, p40)
	
	p38 = p38 + "
	|"+p39+": "+p40;
	
	//p41 = p38.Add();
	//p41.Level = p39;
	//p41.Description = p40;
	
EndProcedure

Procedure WriteLogToFile(p42, p43) 
	
	If p43.Count() = 0 Then
		Return;
	EndIf;
	p45 = New TextDocument;
	For each p46 In p43 Do
		p45.AddLine(p46.Level);
		p45.AddLine(p46.Description);
	EndDo;
	p45.Write(p42);
	
EndProcedure

Procedure RegisterChangeInTheExchange(p50, p51 = Undefined, p52) Export 
	
	p53 = New Query;
	If p51 = Undefined Then
		p53.SetParameter("ThisHost", ExchangePlans[p50].ThisNode());
	Else p53.SetParameter("ExchangeHost", p51);
	EndIf;
	p53.Text = "SELECT 	" + p50 + ".Ref ИЗ 	ExchangePlan." + p50 + " AS " + p50 + ?(p51 = Undefined, " WHERE " + p50 + ".Ref <> &ThisHost ", " WHERE " + p50 + ".Ref = &ExchangeHost ");
	p54 = p53.Execute().Unload();
	For Each p55 In p54 Do
		If Not p55.Ref = ExchangePlans[p50].ThisNode() Then
			ExchangePlans.RecordChanges(p55.Ref, p52);
		EndIf;
	EndDo;
EndProcedure  



//FTP procedures

// функция проверяет настройки FTP подключения
Функция CheckFTPConnectionSettings(ДанныеНастройки, MessageVT, ИмяКаталогаСервера = "", ИмяFTPСервера = "" , Соединение = Неопределено) Экспорт
	
	// нужно по полному имени получить имя сервера и имя каталога
	GetServerAndDirectoryName(ДанныеНастройки.FTPAdress, ИмяFTPСервера, ИмяКаталогаСервера);
	
	// если не задано имя сервера или каталога то невозможно обмениваться данными
	Если ПустаяСтрока(ИмяFTPСервера) Тогда
		
		WriteEventToLogString(MessageVT,EventLogLevel.Error,"FTP exchange server not found.");

		Возврат Ложь;
		
	КонецЕсли;
	
	// соединение
	Соединение = GetFTPConnection(ИмяFTPСервера, ДанныеНастройки, MessageVT);
	Если Соединение = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;
	
	// каталог проверяем
	НаличиеКаталога = CheckDirectoryExistOnFTPServer(Соединение, ИмяКаталогаСервера, MessageVT);
	Если Не НаличиеКаталога Тогда 
		Возврат Ложь;
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

Функция NormalizeFTPadress(Знач FTPАдрес) Экспорт
	
	ИтоговыйАдрес = СокрЛП(FTPАдрес);
	ПозицияFTP = Найти(Врег(ИтоговыйАдрес), "FTP://");
	
	Если ПозицияFTP = 1 Тогда
		
		ИтоговыйАдрес = Сред(ИтоговыйАдрес, 7);	
		
	КонецЕсли;
	
	Возврат ИтоговыйАдрес;
	
КонецФункции

// Процедура по адресу FTP обмена получает имя сервера и имя каталога обмена
Процедура GetServerAndDirectoryName(Знач ПолныйFTPАдрес, ИмяСервера, ИмяКаталога)
	
	АдресОбмена = NormalizeFTPadress(ПолныйFTPАдрес);
	
	// принцип получения адреса такой, все что до первой черты / или \ - это имя сервера, потом каталог
	АдресОбмена = СтрЗаменить(АдресОбмена, "\", "/");
	
	ПозицияПрямогоСлеша = Найти(АдресОбмена, "/");
	
	Если ПозицияПрямогоСлеша = 0 Тогда
		
		ИмяСервера = АдресОбмена;
		ИмяКаталога = "";
		
		
	Иначе
		
		ИмяСервера = Сред(АдресОбмена, 1, ПозицияПрямогоСлеша - 1);
		ИмяКаталога = Сред(АдресОбмена, ПозицияПрямогоСлеша);
		
		// последний должен быть слеш у имени каталога
		Если Сред(ИмяКаталога, СтрДлина(ИмяКаталога)) <> "/" Тогда
			
			ИмяКаталога = ИмяКаталога + "/";
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

// функция выполняет FTP подключение к серверу
Функция GetFTPConnection(Знач ИмяFTPСервера, НастройкиОбмена, MessageVT)       
	
	Попытка
		
		Соединение = Новый FTPСоединение(ИмяFTPСервера, НастройкиОбмена.FTPPort, 
				НастройкиОбмена.FTPUser, НастройкиОбмена.FTPPassword, ,НастройкиОбмена.FTPPassiveConnection);						
				
	Исключение
			
		// ошибка при подключении к ftp
		WriteEventToLogString(MessageVT,EventLogLevel.Error,"FTP connecting error: " + ИмяFTPСервера + " ! " + ОписаниеОшибки());
		
		Возврат Неопределено;
		
	КонецПопытки;
	
	Возврат Соединение;
	
КонецФункции

// функция проверяет наличие катаога на FTP сервере
Функция CheckDirectoryExistOnFTPServer(Соединение, Знач ИмяКаталогаСервера, MessageVT)
	
	Если ПустаяСтрока(ИмяКаталогаСервера) Тогда
		Возврат Истина;
	КонецЕсли;
	
	//надо сначала проверить что сам каталог доступа есть
	Попытка
		
		МассивНайденныхКаталогов = Соединение.НайтиФайлы(ИмяКаталогаСервера, "");
		
	Исключение
		
		// ошибка при подключении к ftp
		WriteEventToLogString(MessageVT,EventLogLevel.Error,"FTP connection error: " + ИмяКаталогаСервера + " ! " + ОписаниеОшибки());
        Возврат Ложь;
		
	КонецПопытки;
	
	Для Каждого НайденныйКаталог Из МассивНайденныхКаталогов Цикл
		
		// если не каталог - то дальше ищем
		Если НЕ НайденныйКаталог.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;
		
		// большие и маленькие буквы считаются различными
		Если НайденныйКаталог.ПолноеИмя + "/" <> ИмяКаталогаСервера Тогда
			Продолжить;
		КонецЕсли;
		
		Возврат Истина;
		
	КонецЦикла;
	
	// если не найден каталог для обмена
	WriteEventToLogString(MessageVT,EventLogLevel.Error,"Not found directory on FTP: " + ИмяКаталогаСервера);
		
	Возврат Ложь;
	
КонецФункции


