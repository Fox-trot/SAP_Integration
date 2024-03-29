﻿
Процедура ПередЗаписью(Отказ, РежимЗаписи)
	
	// *Запрет
	Регистратор=ЭтотОбъект.Отбор.Регистратор.Значение;
	
	ТекстОшибки = ПроверкаПериодаЗаписей("РегистрБухгалтерии.Хозрасчетный",ЭтотОбъект.Выгрузить(),Регистратор, Отказ);
	
	Если Отказ Тогда
		Сообщить(ТекстОшибки);
		Возврат;
	КонецЕсли;
	
	Если Количество()>0 Тогда
		Заголовок = СокрЛП(ЭтотОбъект.Отбор.Регистратор.Значение);
	Иначе
		Возврат;
	КонецЕсли; 
	
	ПолныеПрава=ложь;
	
	ТекущийПользователь = ПользователиИнформационнойБазы.ТекущийПользователь();
	Для каждого РольПользователя Из ТекущийПользователь.Роли Цикл
		Если РольПользователя.Имя="ПолныеПрава" Тогда
			ПолныеПрава = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;


	НомерПроводки=0;
	
	Для Каждого Проводка Из ЭтотОбъект Цикл
		
		НомерПроводки=НомерПроводки+1;
		Если ЗначениеНеЗаполнено(Проводка.СчетДт) И не Проводка.СчетКт.Забалансовый Тогда
			СообщитьОбОшибке("Проводка № "+(НомерПроводки) +" <"+Проводка.Содержание+">: не заполнен счет дебета.",Отказ,Заголовок);
		КонецЕсли;
		Если ЗначениеНеЗаполнено(Проводка.СчетКт) И не Проводка.СчетДт.Забалансовый Тогда
			СообщитьОбОшибке("Проводка № "+(НомерПроводки) +" <"+Проводка.Содержание+">: не заполнен счет кредита.",Отказ,Заголовок);
		КонецЕсли;
		
		//Если Не ПолныеПрава Тогда
		//Если не НеПроверятьРегистратор(Типзнч(ЭтотОбъект.Отбор.регистратор.значение)) Тогда		
		//	Для н=1 По мин(Проводка.СчетДт.ВидыСубконто.Количество(),3) Цикл
		//		Если ЗначениеНеЗаполнено(ЗначениеСубконтоПоНомеру(н,Проводка.СчетДт,Проводка.СубконтоДт)) Тогда
		//			СообщитьОбОшибке("Проводка № "+(НомерПроводки) +" <"+Проводка.Содержание+">: не заполнено субконто № "+Строка(н)+".",Отказ,Заголовок);
		//		КонецЕсли; 
		//	КонецЦикла; 
		//	
		//	Для н=1 По мин(Проводка.СчетКт.ВидыСубконто.Количество(),3) Цикл
		//		Если ЗначениеНеЗаполнено(ЗначениеСубконтоПоНомеру(н,Проводка.СчетКт,Проводка.СубконтоКт)) Тогда
		//			СообщитьОбОшибке("Проводка № "+(НомерПроводки) +" <"+Проводка.Содержание+">: не заполнено субконто № "+Строка(н)+".",Отказ,Заголовок);
		//		КонецЕсли; 
		//	КонецЦикла; 
		//КонецЕсли;
		//КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ЗначениеСубконтоПоНомеру(НомерСубконто,Счет,НаборСубконто) Экспорт

   Если ЗначениеНеЗаполнено(Счет) Тогда
       Возврат Неопределено;
   КонецЕсли;
   
   ВидыСубконто = Счет.ВидыСубконто;
   
   Если НомерСубконто>ВидыСубконто.Количество() Тогда
       Возврат Неопределено;
   КонецЕсли;
   
   ВидСубконто = ВидыСубконто.Получить(НомерСубконто-1).ВидСубконто;
   
   Возврат НаборСубконто[ВидСубконто];

КонецФункции // ЗначениеСубконтоПоНомеру 

Функция НеПроверятьРегистратор(ТипРегистратора)
	
	Если ТипРегистратора=Тип("ДокументСсылка.ЗакрытиеМесяца") Тогда		
		Возврат истина;
	ИначеЕсли ТипРегистратора=Тип("ДокументСсылка.ЗакрытиеАвансовыхСчетов") Тогда		
		Возврат истина;
	ИначеЕсли ТипРегистратора=Тип("ДокументСсылка.ПереоценкаВалютныхСчетов") Тогда		
		Возврат истина;
	ИначеЕсли ТипРегистратора=Тип("ДокументСсылка.ПриходНоменклатурыВнутренний") Тогда		
		Возврат истина;
	ИначеЕсли ТипРегистратора=Тип("ДокументСсылка.ПринятиеКУчетуОС") Тогда		
		Возврат истина;
	КонецЕсли;
	
	Возврат ложь;
КонецФункции	
