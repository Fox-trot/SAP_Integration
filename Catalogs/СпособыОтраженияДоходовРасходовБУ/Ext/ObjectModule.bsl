﻿
Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	
	//Если Счет.Пустая() Тогда
	//	
	//	Предупреждение("Не заполнен счет!");
	//	Отказ=Истина;
	//
	//КонецЕсли; 
	//Если не ПустаяСтрока(СтрокаСообщения) Тогда
	//	СообщитьОбОшибке("Обнаружены ошибки в заполнении способов отражения расходов:"+СтрокаСообщения,Отказ); 
	//КонецЕсли; 
	
КонецПроцедуры

Процедура ПриУстановкеНовогоКода(СтандартнаяОбработка, Префикс)
	ДобавитьПрефиксУзла(Префикс);
КонецПроцедуры
