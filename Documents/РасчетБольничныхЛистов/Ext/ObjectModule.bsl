﻿
Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	
	ДобавитьПрефиксУзла(Префикс);
	
КонецПроцедуры

Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("ПечатьРассчета","Печать");
	
КонецФункции

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

Функция ЕстьРасчетыЗаПериод()
	
	РасширениеИнтервала=100*24*60*60;
	
	Отбор=новый Структура;
	Отбор.Вставить("Сотрудник",Сотрудник);
	
	Выборка=Документы.РасчетБольничныхЛистов.Выбрать(НачалоДня(Дата-РасширениеИнтервала),КонецДня(Дата+РасширениеИнтервала),Отбор);
	
	Пока Выборка.Следующий()  Цикл
		
		Если Выборка.Ссылка=Ссылка Тогда
			Продолжить;
		КонецЕсли;
		
		Если ПериодыПересекаются(Начало,Окончание,Выборка.Начало,Выборка.Окончание) Тогда
			Возврат Истина;
		КонецЕсли; 
		
	КонецЦикла; 
	
	Возврат Ложь;
	
КонецФункции

Процедура ОбработкаПроведения(Отказ, Режим)
	
	Если ЕстьРасчетыЗаПериод() Тогда
		//Отказ=истина;
		Сообщить("За указанный период расчет б/л уже вводился");
	КонецЕсли; 
	
	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);
	
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	
	ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента);
	
	ДвиженияПоРегистрам(Отказ, Заголовок, СтруктураШапкиДокумента);
	
КонецПроцедуры     

Процедура ДвиженияПоРегистрам(Отказ, Заголовок, СтруктураШапкиДокумента)
	
	Расчет=Движения.ДополнительныеРасчеты.Добавить();
	Расчет.Период=Дата;
	Расчет.Организация=Организация;
	Расчет.Сотрудник=Сотрудник;
	Расчет.ВидРасчета=ВидРасчета;
	Расчет.СпособРасчета=Перечисления.СпособыРасчетаНачисленияУдержания.Суммой;
	Расчет.Параметр=СуммаКНачислению;
	
	СведенияОСотруднике=СведенияОСотруднике(Сотрудник,Организация,Начало);

	д=Начало;
	Пока д<=Окончание Цикл
		
		Расчет=Движения.УчетРабочегоВремени.Добавить();
		Расчет.Организация=Организация;
		Расчет.Сотрудник=Сотрудник;
		
		ЗаполнитьЗначенияСвойств(Расчет,СведенияОСотруднике);
		
		Расчет.СпособОтраженияРасходов=СведенияОСотруднике.СпособОтраженияРасходовБУ;
		Расчет.ПодразделениеОрганизации=СведенияОСотруднике.Подразделение;
		Расчет.ВидУчетаВремени=Перечисления.ВидыУчетаВремени.ПоЧасам;
		Расчет.ВидРасчета=ПланыВидовРасчета.РасчетыУчетаРабочегоВремени.Неявка;
		Расчет.ПериодРегистрации=НачалоМесяца(д);
		Расчет.ПериодДействияНачало=д;
		Расчет.ПериодДействияКонец=КонецДня(мин(КонецМесяца(д),Окончание));
		Расчет.Маркер="Б";
		
		д=КонецМесяца(д)+1;
			
	КонецЦикла;
	
	
КонецПроцедуры

Процедура ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента)
	
	//Проверяем заполнение шапки
	СтруктураОбязательныхПолей = Новый Структура("Организация");
	СтруктураОбязательныхПолей.Вставить("Сотрудник","Не выбран сотрудник.");
	СтруктураОбязательныхПолей.Вставить("ВидРасчета","Не выбран вид расчета.");
	СтруктураОбязательныхПолей.Вставить("Начало","Не заполнена дата начала болезни.");
	СтруктураОбязательныхПолей.Вставить("Окончание","Не заполнена дата окончания болезни.");
	СтруктураОбязательныхПолей.Вставить("Процент","Не заполнен процент.");
	
	ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	
	//Проверяем заполнение табличной части 
	//
	//СтруктураПолей = Новый Структура();
	//СтруктураПолей.Вставить("Номенклатура","Не выбрана номенклатура");
	////СтруктураПолей.Вставить("Цена","Не введена цена");
	////СтруктураПолей.Вставить("Количество","Не введено количество");
	//СтруктураПолей.Вставить("Сумма","Не введена сумма");
	//СтруктураПолей.Вставить("Всего","Не введена сумма");
	//
	//ПроверитьЗаполнениеТабличнойЧастиПлатежногоДокумента(ЭтотОбъект, "Номенклатура", СтруктураПолей, Отказ, Заголовок);
	
КонецПроцедуры


Функция ПечатьРассчета(ИмяМакета)
	
	СведенияОСотруднике=СведенияОСотруднике(Сотрудник,Организация,Начало);
	
	ТабДок = Новый ТабличныйДокумент;
	
	Макет = ПолучитьМакет("Рассчет");
	
	Область = Макет.ПолучитьОбласть("Заголовок");
	
	Область.Параметры.Номер = ПолучитьНомерНаПечать(ЭтотОбъект);
	Область.Параметры.Дата = Формат(Дата,"ДФ=dd.MM.yyyy");
	Область.Параметры.НомерБЛ = НомерБЛ;
	Область.Параметры.Начало = Формат(Начало,"ДФ=dd.MM.yyyy");
	Область.Параметры.Окончание = Формат(Окончание,"ДФ=dd.MM.yyyy");
	Область.Параметры.ДниПоБолезни = ДниПоБолезни;
	Область.Параметры.Процент = Процент;
	Область.Параметры.Сотрудник = Сотрудник;
	Область.Параметры.ТабельныйНомер = Сотрудник.Код;
	Область.Параметры.Подразделение = СведенияОСотруднике.Подразделение;
	
	ТабДок.Вывести(Область);
	
	
	
	Если Премии.Итог("Сумма")<>0 Тогда
		
		Область = Макет.ПолучитьОбласть("ШапкаТаблицы");
		ТабДок.Вывести(Область);
		
		Область = Макет.ПолучитьОбласть("СтрокаВыборки");
		Для Каждого СтрокаПремии из Премии Цикл
			Область.Параметры.Заполнить(СтрокаПремии);
			ТабДок.Вывести(Область);
		КонецЦикла; 
		
		Область = Макет.ПолучитьОбласть("ИтогТаблицы");
		Область.Параметры.ВсегоПремий = Премии.Итог("Сумма");
		ТабДок.Вывести(Область);
		
	КонецЕсли; 
	
	Область = Макет.ПолучитьОбласть("Итог");
	Область.Параметры.СредняяСуммаПремий = СредняяСуммаПремий;
	Область.Параметры.МесячныйЗаработок = МесячныйЗаработок;
	Область.Параметры.СреднедневнойЗаработок = СреднедневнойЗаработок;
	Область.Параметры.СуммаКНачислению = СуммаКНачислению;
	ТабДок.Вывести(Область);
	
	ТабДок.ФиксацияСверху=0;
	ТабДок.ФиксацияСлева=0;
	ТабДок.ЭкземпляровНаСтранице=0;
	ТабДок.ТолькоПросмотр = Истина;
	ТабДок.КлючПараметровПечати="КПП_РасчетБольничныхЛистов";
	
	Возврат ТабДок;
КонецФункции

Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	
	// Получить экземпляр документа на печать
	
	ТабДокумент = ПечатьРассчета(ИмяМакета);
		
	НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, "");
	
КонецПроцедуры // Печать()

Процедура ОбработкаУдаленияПроведения(Отказ)
	
	
КонецПроцедуры

