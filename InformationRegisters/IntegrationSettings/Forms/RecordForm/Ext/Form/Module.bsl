
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	фИмеется = Ложь;
	Если ЗначениеЗаполнено(Record.ExchangeHost) Тогда
		объект = РеквизитФормыВЗначение("Record");
		
		Бинар = объект.RulesStorage.Получить();
		
		Если ТипЗнч(Бинар) = Тип("ДвоичныеДанные") Тогда
			имяВрем = ПолучитьИмяВременногоФайла(".xml");
			Бинар.Записать(имяВрем);
			п28 = Новый Файл(имяВрем);
			Если п28.Существует() Тогда
				фАдрес = ПоместитьВоВременноеХранилище(Бинар,UUID);
				фИмеется = Истина;
				УдалитьФайлы(имяВрем);
			КонецЕсли;
		КонецЕсли; 
	
	КонецЕсли; 
	
EndProcedure

&AtServer
Procedure BeforeWriteAtServer(Cancel, CurrentObject, WriteParameters)
	
	Если ЗначениеЗаполнено(фАдрес) И фИмеется Тогда
		CurrentObject.RulesStorage = Новый ХранилищеЗначения(ПолучитьИзВременногоХранилища(фАдрес));
	КонецЕсли; 
	
EndProcedure

&AtClient
Procedure ЗагрузитьФайлОбмена(Command)
	
	Адрес = "";
	НачИмя = "";
	КонИмя = "";
	ПоместитьФайл(Адрес,НачИмя,КонИмя,Истина,UUID);
	
	Если ЗначениеЗаполнено(Адрес) Тогда
		фАдрес = Адрес;
		фИмеется = Истина;
		ф = Новый Файл(КонИмя);
		Record.ExchangeRulesName = ф.Name;
	КонецЕсли; 
	
EndProcedure

&AtClient
Procedure ВыгрузитьФайлОбмена(Command)
	
	Если ЗначениеЗаполнено(фАдрес) Тогда
		ПолучитьФайл(фАдрес,, Истина);
	Иначе 
		Предупреждение(НСтр("ru='Не существуют файла для сохранения';uz='Kaydetmek için dosya mevcut değil'"));
	КонецЕсли; 
	
EndProcedure

&AtClient
Procedure ConnectionStringOnChange(Item)
	
	Record.ConnectionString = Upper(Record.ConnectionString);
	
EndProcedure

&НаКлиенте
Процедура ExchangeProtocolПриИзменении(Элемент)
	
	ОпределитьСтраницуПоТипуПротокола();
	
КонецПроцедуры

&НаКлиенте
Процедура ОпределитьСтраницуПоТипуПротокола()

	PageName = "PageDirectory";
	
	Если Record.ExchangeProtocol = 1 Тогда
		PageName = "PageFTP";
	КонецЕсли;
	
	Элементы.PagesProtocol.ТекущаяСтраница = Элементы[PageName];

КонецПроцедуры


&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ОпределитьСтраницуПоТипуПротокола();
	
КонецПроцедуры


&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	Если Record.ExchangeProtocol = 1 Тогда
		
		Если ПустаяСтрока(Record.FTPAdress) Тогда
			Отказ = Истина;
			_СообщениеПользователю("Please set up adress for FTP connection","FTPAdress");
		КонецЕсли; 
		
		Если Не ЗначениеЗаполнено(Record.FTPPort) Тогда
			Отказ = Истина;
			_СообщениеПользователю("Please set up port for FTP connection","FTPPort");
		КонецЕсли; 
		
		Если Не ЗначениеЗаполнено(Record.FTPUser) Тогда
			Отказ = Истина;
			_СообщениеПользователю("Please set up user for FTP connection","FTPUser");
		КонецЕсли; 
		
		Если Не ЗначениеЗаполнено(Record.FTPPassword) Тогда
			Отказ = Истина;
			_СообщениеПользователю("Please set up password for FTP connection","FTPPassword");
		КонецЕсли; 
		
	Иначе 
		
		Если ПустаяСтрока(Record.ExchangeDirectory) Тогда
			Отказ = Истина;
			_СообщениеПользователю("Please set up exchange directory","ExchangeDirectory");
		КонецЕсли; 
		
	КонецЕсли; 
	
КонецПроцедуры
 
&НаКлиенте
Процедура _СообщениеПользователю(Текст,Поле)
	
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = Текст;
	
	Если Не ПустаяСтрока(Поле) Тогда
		Сообщение.Поле = Поле;
	КонецЕсли; 
	
	Сообщение.Сообщить(); 
	
КонецПроцедуры // СообщениеПользователю()

&НаСервереБезКонтекста
Процедура ВыполнитьОбменНаСервере()
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьОбмен(Команда)
	ExchangeDataServer.PerformDataSyncronization()
КонецПроцедуры
 

