﻿
Перем Расходы;
Перем Передача;
Перем ОстаткиИВыпускГП;
Перем ТаблицаДвижений;
Перем Полуфабрикаты;


Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	
	ДобавитьПрефиксУзла(Префикс);
	
КонецПроцедуры

Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("","");
	
КонецФункции

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	
	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);
	
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	
	ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента);
	
	Если не Отказ Тогда
		
		Если РаспределятьКосвенныеРасходы Тогда
			РаспределитьРасходы(ПланыСчетов.Хозрасчетный.А2020,ВидБазыРаспределенияКосвенныхРасходов);
		КонецЕсли;
		
		Если РаспределятьОбщепроизводственныеРасходы Тогда
			РаспределитьРасходы(ПланыСчетов.Хозрасчетный.А2510,ВидБазыРаспределенияОбщепроизводственныхРасходов,ложь);
		КонецЕсли;
		
		Если РаспределятьКосвенныеРасходы или  РаспределятьОбщепроизводственныеРасходы Тогда
			Движения.Хозрасчетный.Записать();
		КонецЕсли;
		
		ЗакрытьОсновноеПроизводство();
		
	КонецЕсли;
	
КонецПроцедуры

Функция ПечатьДокумента(ИмяМакета)
	ТабДок = Новый ТабличныйДокумент;
	
	//Макет = ПолучитьМакет(ИмяМакета);
	
	//Руководители = ОтветственныеЛица(Организация, Дата);	
	//Область.Параметры.Заполнить(Руководители);
	//Область = Макет.ПолучитьОбласть("ПП");
	//Область.Параметры.Номер = ПолучитьНомерНаПечать(ЭтотОбъект);
	
	//ТабДок.Вывести(Область);
	//ТабДок.ФиксацияСверху=0;
	//ТабДок.ФиксацияСлева=0;
	//ТабДок.ЭкземпляровНаСтранице=0;
	//ТабДок.ТолькоПросмотр = Истина;
	
	Возврат ТабДок;
КонецФункции

Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	
	// Получить экземпляр документа на печать
	
	ТабДокумент = ПечатьДокумента(ИмяМакета);
		
	НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, "");
	
КонецПроцедуры // Печать()

Процедура ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента)
	
	//Проверяем заполнение шапки
	СтруктураОбязательныхПолей = Новый Структура("Организация");
	
	Если РаспределятьКосвенныеРасходы Тогда
		СтруктураОбязательныхПолей.Вставить("ВидБазыРаспределенияКосвенныхРасходов","Не выбран вид базы распределения косвенных расходов.");
	КонецЕсли;
	
	Если РаспределятьОбщепроизводственныеРасходы Тогда
		СтруктураОбязательныхПолей.Вставить("ВидБазыРаспределенияОбщепроизводственныхРасходов","Не выбран вид базы распределения общепроизв. расходов.");
	КонецЕсли;
	
	
	ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	//
	////Проверяем заполнение табличной части 
	//
	//СтруктураОбязательныхПолей = Новый Структура();
	//СтруктураОбязательныхПолей.Вставить("Номенклатура","Не выбрана номенклатура");
	//ПроверитьЗаполнениеТабличнойЧастиПлатежногоДокумента(ЭтотОбъект, "Номенклатура", СтруктураПолей, Отказ, Заголовок);
	
КонецПроцедуры

Процедура РаспределитьРасходы(РаспределяемыйСчет,ВидБазыРаспределения,РаспределятьПоПодразделениям=истина)
	
	ДатаРасчета=Дата;
	
	Результат=РасчетСебестоимости.ПолучитьРасходыПоСчету(Организация,РаспределяемыйСчет,КонецМесяца(ДатаРасчета)+1);
	
	Если Результат.Пустой() Тогда
		Возврат;
	КонецЕсли;	
	
	БазаРаспределения=РасчетСебестоимости.ПолучитьБазуРаспределенияРасходов(Организация,ВидБазыРаспределения,НачалоМесяца(ДатаРасчета),КонецМесяца(ДатаРасчета));
	
	ТаблицаДвижений=СоздатьТаблицуДляХраненияПроводок_Хозрасчетный();
	
	Выборка=Результат.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		РасчетСебестоимости.РаспределитьПоБазе(Дата,Организация,ТаблицаДвижений,Выборка,БазаРаспределения,РаспределятьПоПодразделениям);
		
	КонецЦикла;	
	
	ЗаписатьВРегистрТаблицуДляХраненияПроводок_Хозрасчетный(Движения.Хозрасчетный,ТаблицаДвижений);
	
КонецПроцедуры	

Процедура ЗакрытьОсновноеПроизводство()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПоследовательностьПодразделенийПриЗакрытииПроизводства.Подразделение КАК Подразделение,
		|	ПоследовательностьПодразделенийПриЗакрытииПроизводства.НомерПоПорядку КАК НомерПоПорядку
		|ИЗ
		|	РегистрСведений.ПоследовательностьПодразделенийПриЗакрытииПроизводства КАК ПоследовательностьПодразделенийПриЗакрытииПроизводства
		|ГДЕ
		|	ПоследовательностьПодразделенийПриЗакрытииПроизводства.Организация = &Организация
		|
		|УПОРЯДОЧИТЬ ПО
		|	НомерПоПорядку
		|ИТОГИ ПО
		|	Подразделение";

	Запрос.УстановитьПараметр("Организация", Организация);

	Результат = Запрос.Выполнить();
    ВыборкаПодразделение = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Результат=ПолучитьРасходы(Организация);
	
	Если Результат.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	Расходы=Результат.Выгрузить();
	Расходы.Колонки.Добавить("ИсходныеДанные");
	Расходы.ЗаполнитьЗначения(Истина,"ИсходныеДанные");
	Расходы.Колонки.Добавить("Досписание");
	Расходы.ЗаполнитьЗначения(Ложь,"Досписание");
	
	Передача=ПолучитьПередачу(Организация,НачалоМесяца(Дата),КонецМесяца(Дата));
	ОстаткиИВыпускГП=ПолучитьОстаткиИВыпускГП(Организация,НачалоМесяца(Дата),КонецМесяца(Дата));
	Полуфабрикаты=ПолучитьПолуфабрикаты(Организация,НачалоМесяца(Дата),КонецМесяца(Дата));
	
	ТаблицаДвижений=СоздатьТаблицуДляХраненияПроводок_Хозрасчетный(); 
	
	Пока ВыборкаПодразделение.Следующий() Цикл
		
		Выборка = ВыборкаПодразделение.Выбрать();
		
		Пока Выборка.Следующий() Цикл
			
			ЗакрытьПодразделение(Выборка);
			
		КонецЦикла;	
		//	Прервать;
		
	КонецЦикла;	
	
		
	ТаблицаДвижений.ЗаполнитьЗначения(Организация,"Организация");
	ТаблицаДвижений.ЗаполнитьЗначения(Дата,"Период");
	
	ЗаписатьВРегистрТаблицуДляХраненияПроводок_Хозрасчетный(Движения.Хозрасчетный,ТаблицаДвижений);
	
КонецПроцедуры	

Процедура ЗакрытьПодразделение(Последовательность)
	
	
	Результат=ВыполнитьЗапросПоРасходамПодразделения(Расходы,Последовательность.Подразделение);	
	
	ВыборкаНоменклатура=Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаНоменклатура.Следующий() Цикл
		
		СписатьПолуфабрикаты(Последовательность.Подразделение,ВыборкаНоменклатура.Номенклатура);
		
		Результат=ВыполнитьЗапросПоРасходамПодразделенияИНоменклатуре(Расходы,Последовательность.Подразделение,ВыборкаНоменклатура.Номенклатура);	
		
		ЗакрытьНоменклатуру(Последовательность.Подразделение,ВыборкаНоменклатура.Номенклатура,Результат);	
		
	КонецЦикла;	
	
	
КонецПроцедуры	

Процедура СписатьПолуфабрикаты(Подразделение,Номенклатура)
	
	Счет2010=ПланыСчетов.Хозрасчетный.А2010;
	Счет2110=ПланыСчетов.Хозрасчетный.А2110;
	
	ОстаткиПолуфабрикатов=ВыполнитьЗапросПоПолуфабрикатам();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ХозрасчетныйОбороты.Субконто1 КАК Номенклатура,
	|	ХозрасчетныйОбороты.Субконто2 КАК Склад,
	|	ХозрасчетныйОбороты.СуммаОборотКт КАК Сумма,
	|	ХозрасчетныйОбороты.КоличествоОборотКт КАК Количество,
	|	ХозрасчетныйОбороты.КорСубконто3
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.Обороты(
	|			&НачалоПериода,
	|			&КонецПериода,
	|			,
	|			Счет = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.а2110),
	|			,
	|			Организация = &Организация
	|				И КорСубконто1 = &Подразделение
	|				И КорСубконто2 = &Номенклатура,
	|			КорСчет = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.а2010),
	|			) КАК ХозрасчетныйОбороты";
	
	Запрос.УстановитьПараметр("КонецПериода", КонецМесяца(Дата));
	Запрос.УстановитьПараметр("НачалоПериода", НачалоМесяца(Дата));
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("Подразделение", Подразделение);
	
	Результат = Запрос.Выполнить();

	Выборка = Результат.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		СтрокиОстаткиПолуфабрикатов=ОстаткиПолуфабрикатов.НайтиСтроки(Новый Структура("Номенклатура,Склад",Выборка.Номенклатура,Выборка.Склад));
		
		Если СтрокиОстаткиПолуфабрикатов.Количество()=0 Тогда
			Продолжить;
		КонецЕсли;
		
		СуммаВПроводку=0;
		Если СтрокиОстаткиПолуфабрикатов[0].Количество<>0 Тогда
			СуммаВПроводку=СтрокиОстаткиПолуфабрикатов[0].Сумма/СтрокиОстаткиПолуфабрикатов[0].Количество*Выборка.Количество-Выборка.Сумма;
		КонецЕсли;	
		
		Если СуммаВПроводку=0 Тогда
			Продолжить;
		КонецЕсли;
		
		Проводка=ТаблицаДвижений.Добавить();
		
		Проводка.СчетДт=Счет2010;
		Проводка.СубконтоДт1=Подразделение;
		Проводка.СубконтоДт2=Номенклатура;
		Проводка.СубконтоДт3=Выборка.КорСубконто3;
		
		Проводка.СчетКт=Счет2110;
		Проводка.СубконтоКт1=Выборка.Номенклатура;
		Проводка.СубконтоКт2=Выборка.Склад;
		
		Проводка.Сумма=СуммаВПроводку;
		
		СтрокаРасходы=Расходы.Добавить();
		СтрокаРасходы.Счет=Счет2010;
		СтрокаРасходы.Субконто1=Подразделение;
		СтрокаРасходы.Субконто2=Номенклатура;
		СтрокаРасходы.Субконто3=Выборка.КорСубконто3;
		СтрокаРасходы.КоличествоСЗ=0;
		СтрокаРасходы.Сумма=СуммаВПроводку;
		СтрокаРасходы.ИсходныеДанные=Ложь;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗакрытьНоменклатуру(Подразделение,Номенклатура,ВыборкаНоменклатура)
	
	Счет2010=ПланыСчетов.Хозрасчетный.А2010;
	Счет2110=ПланыСчетов.Хозрасчетный.А2110;
	Счет2810=ПланыСчетов.Хозрасчетный.А2810;
	
	СтрокиПередача=Передача.НайтиСтроки(Новый Структура("Субконто1,Субконто2",Подразделение,Номенклатура));
	
	Если СтрокиПередача.Количество()=0 Тогда
		Возврат;
	КонецЕсли;
	
	
	ОбщийВыпуск=0;
	
	СтрокиОстаткиИВыпускГП=ОстаткиИВыпускГП.НайтиСтроки(Новый Структура("Подразделение,Номенклатура",Подразделение,Номенклатура));
	
	Если СтрокиОстаткиИВыпускГП.Количество()<>0 Тогда
		
		ОбщийВыпуск=СтрокиОстаткиИВыпускГП[0].Выпуск+СтрокиОстаткиИВыпускГП[0].Незавершенка;
		
	КонецЕсли;
	
	
	Если ОбщийВыпуск=0 Тогда
		Возврат;
	КонецЕсли;
	
	ВыборкаДетали=ВыборкаНоменклатура.Выбрать();
	
	Пока ВыборкаДетали.Следующий() Цикл
		
		СуммаДляРаспределения=ВыборкаДетали.Сумма;
		ОстатокСумма=СуммаДляРаспределения;
		КоличествоДляРаспределения=ВыборкаДетали.КоличествоСЗ;
		ОстатокКоличество=КоличествоДляРаспределения;
		
		Для н=1 по СтрокиПередача.Количество() Цикл
			
			СтрокаПередача=СтрокиПередача[н-1];
			
			//Если н=СтрокиПередача.Количество() Тогда
			//	
			//	СуммаВПроводку=ОстатокСумма;
			//	
			//	КоличествоВПроводку=ОстатокКоличество;
			//	
			//Иначе
			
			СуммаВПроводку=Окр(СуммаДляРаспределения/ОбщийВыпуск*СтрокаПередача.Количество,2);
			ОстатокСумма=ОстатокСумма-СуммаВПроводку;
			
			КоличествоВПроводку=Окр(КоличествоДляРаспределения/ОбщийВыпуск*СтрокаПередача.Количество,5);
			ОстатокКоличество=ОстатокКоличество-КоличествоВПроводку;
			
			//КонецЕсли;
			
			Проводка=ТаблицаДвижений.Добавить();
			
			Проводка.СчетДт=СтрокаПередача.КорСчет;
			Проводка.СубконтоДт1=СтрокаПередача.КорСубконто1;
			Проводка.СубконтоДт2=СтрокаПередача.КорСубконто2;
			Проводка.СубконтоДт3=СтрокаПередача.КорСубконто3;
			
			Проводка.СчетКт=Счет2010;
			Проводка.СубконтоКт1=ВыборкаДетали.Субконто1;
			Проводка.СубконтоКт2=ВыборкаДетали.Субконто2;
			Проводка.СубконтоКт3=ВыборкаДетали.Субконто3;
			
			Если Проводка.СчетДт.КоличественныйСЗ Тогда
				Проводка.КоличествоСзДт=КоличествоВПроводку;
			КонецЕсли;
			
			Проводка.КоличествоСзКт=КоличествоВПроводку;
			
			Проводка.Сумма=СуммаВПроводку;
			
			Если Проводка.СчетДт=Счет2010 Тогда	
				
				СтрокаРасходы=Расходы.Добавить();
				СтрокаРасходы.Счет=Счет2010;
				СтрокаРасходы.Субконто1=Проводка.СубконтоДт1;
				СтрокаРасходы.Субконто2=Проводка.СубконтоДт2;
				СтрокаРасходы.Субконто3=Проводка.СубконтоДт3;
				СтрокаРасходы.КоличествоСЗ=Проводка.КоличествоСзДт;
				СтрокаРасходы.Сумма=Проводка.Сумма;
				СтрокаРасходы.ИсходныеДанные=Ложь;
				
			КонецЕсли;	
			
			Если Проводка.СчетДт=Счет2110 Тогда	
				
				СтрокаРасходы=Полуфабрикаты.Добавить();
				СтрокаРасходы.Номенклатура=Проводка.СубконтоДт1;
				СтрокаРасходы.Склад=Проводка.СубконтоДт2;
				СтрокаРасходы.Сумма=Проводка.Сумма;
				СтрокаРасходы.Количество=0;
				
			КонецЕсли;	
			
		КонецЦикла;	
		
	КонецЦикла;	
	
КонецПроцедуры

Функция ВыполнитьЗапросПоПолуфабрикатам()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Полуфабрикаты.Номенклатура,
	|	Полуфабрикаты.Склад,
	|	Полуфабрикаты.Количество,
	|	Полуфабрикаты.Сумма
	|ПОМЕСТИТЬ Полуфабрикаты
	|ИЗ
	|	&Полуфабрикаты КАК Полуфабрикаты
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Полуфабрикаты.Номенклатура КАК Номенклатура,
	|	Полуфабрикаты.Склад КАК Склад,
	|	СУММА(Полуфабрикаты.Количество) КАК Количество,
	|	СУММА(Полуфабрикаты.Сумма) КАК Сумма
	|ИЗ
	|	Полуфабрикаты КАК Полуфабрикаты
	|
	|СГРУППИРОВАТЬ ПО
	|	Полуфабрикаты.Номенклатура,
	|	Полуфабрикаты.Склад
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|УНИЧТОЖИТЬ Полуфабрикаты";
	
	Запрос.УстановитьПараметр("Полуфабрикаты",Полуфабрикаты);
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции	

Функция ВыполнитьЗапросПоРасходамПодразделения(Расходы,Подразделение)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Расходы.Субконто1,
	|	Расходы.Субконто2
	|ПОМЕСТИТЬ Расходы
	|ИЗ
	|	&Расходы КАК Расходы
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Расходы.Субконто2 КАК Номенклатура
	|ИЗ
	|	Расходы КАК Расходы
	|ГДЕ
	|	Расходы.Субконто1 = &Подразделение
	|
	|СГРУППИРОВАТЬ ПО
	|	Расходы.Субконто2
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|УНИЧТОЖИТЬ Расходы";
	
	Запрос.УстановитьПараметр("Расходы",Расходы);
	Запрос.УстановитьПараметр("Подразделение",Подразделение);
	
	Возврат Запрос.Выполнить();
	
КонецФункции	

Функция ВыполнитьЗапросПоРасходамПодразделенияИНоменклатуре(Расходы,Подразделение,Номенклатура)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Расходы.Субконто1,
	|	Расходы.Субконто2,
	|	Расходы.Субконто3,
	|	Расходы.Субконто4,
	|	Расходы.Сумма,
	|	Расходы.КоличествоСЗ
	|ПОМЕСТИТЬ Расходы
	|ИЗ
	|	&Расходы КАК Расходы
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Расходы.Субконто1 КАК Субконто1,
	|	Расходы.Субконто2 КАК Субконто2,
	|	Расходы.Субконто3,
	|	Расходы.Субконто4,
	|	СУММА(Расходы.Сумма) КАК Сумма,
	|	СУММА(Расходы.КоличествоСЗ) КАК КоличествоСЗ
	|ИЗ
	|	Расходы КАК Расходы
	|ГДЕ
	|	Расходы.Субконто1 = &Подразделение
	|	И Расходы.Субконто2 = &Номенклатура
	|
	|СГРУППИРОВАТЬ ПО
	|	Расходы.Субконто1,
	|	Расходы.Субконто2,
	|	Расходы.Субконто3,
	|	Расходы.Субконто4
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|УНИЧТОЖИТЬ Расходы";
	
	Запрос.УстановитьПараметр("Расходы",Расходы);
	Запрос.УстановитьПараметр("Подразделение",Подразделение);
	Запрос.УстановитьПараметр("Номенклатура",Номенклатура);
	
	Возврат Запрос.Выполнить();
	
КонецФункции	

Функция ПолучитьОстаткиИВыпускГП(Организация,НачалоПериода,КонецПериода) Экспорт
	
	Запрос=Новый Запрос;
	Запрос.Текст=
	"ВЫБРАТЬ
	|	ХозрасчетныйОстаткиИОбороты.Субконто1 КАК Подразделение,
	|	ХозрасчетныйОстаткиИОбороты.Субконто2 КАК Номенклатура,
	|	СУММА(ХозрасчетныйОстаткиИОбороты.КоличествоОборотДт) КАК Выпуск,
	|	СУММА(ХозрасчетныйОстаткиИОбороты.КоличествоНачальныйОстатокДт) КАК Незавершенка
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.ОстаткиИОбороты(
	|			&НачалоПериода,
	|			&КонецПериода,
	|			,
	|			,
	|			Счет = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.А2010),
	|			,
	|			Организация = &Организация) КАК ХозрасчетныйОстаткиИОбороты
	|
	|СГРУППИРОВАТЬ ПО
	|	ХозрасчетныйОстаткиИОбороты.Субконто1,
	|	ХозрасчетныйОстаткиИОбороты.Субконто2";
	
	Запрос.УстановитьПараметр("Организация",Организация);
	Запрос.УстановитьПараметр("НачалоПериода",НачалоПериода);
	Запрос.УстановитьПараметр("КонецПериода",КонецПериода);
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции	

Функция ПолучитьПередачу(Организация,НачалоПериода,КонецПериода) Экспорт
	
	Запрос=Новый Запрос;
	Запрос.Текст=
	"ВЫБРАТЬ
	|	ХозрасчетныйОбороты.Субконто1,
	|	ХозрасчетныйОбороты.Субконто2,
	|	ХозрасчетныйОбороты.КоличествоОборотКт КАК Количество,
	|	ХозрасчетныйОбороты.КорСчет,
	|	ХозрасчетныйОбороты.КорСубконто1,
	|	ХозрасчетныйОбороты.КорСубконто2,
	|	ХозрасчетныйОбороты.КорСубконто3
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.Обороты(&НачалоПериода, &КонецПериода, , Счет = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.А2010), , Организация = &Организация, , ) КАК ХозрасчетныйОбороты";
	
	Запрос.УстановитьПараметр("Организация",Организация);
	Запрос.УстановитьПараметр("НачалоПериода",НачалоПериода);
	Запрос.УстановитьПараметр("КонецПериода",КонецПериода);
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции	

Функция ПолучитьРасходы(Организация) Экспорт
	
	Запрос=Новый Запрос;
	Запрос.Текст=
	"ВЫБРАТЬ
	|	ХозрасчетныйОстатки.Счет,
	|	ХозрасчетныйОстатки.Субконто1,
	|	ХозрасчетныйОстатки.Субконто2,
	|	ХозрасчетныйОстатки.Субконто3,
	|	ХозрасчетныйОстатки.Субконто4,
	|	ХозрасчетныйОстатки.СуммаОстатокДт КАК Сумма,
	|	ХозрасчетныйОстатки.КоличествоСЗОстатокДт КАК КоличествоСЗ,
	|	ХозрасчетныйОстатки.КоличествоОстатокДт КАК Количество
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.Остатки(&ДатаОстатка, Счет В (&Счета), , Организация = &Организация) КАК ХозрасчетныйОстатки";
	
	Запрос.УстановитьПараметр("Организация",Организация);
	Счета=Новый СписокЗначений;
	Счета.Добавить(ПланыСчетов.Хозрасчетный.А2010);
	Запрос.УстановитьПараметр("Счета",Счета);
	Запрос.УстановитьПараметр("ДатаОстатка",КонецМесяца(Дата)+1);
	
	Возврат Запрос.Выполнить();
	
КонецФункции	

Функция ПолучитьПолуфабрикаты(Организация,НачалоПериода,КонецПериода) Экспорт
	
	Запрос=Новый Запрос;
	Запрос.Текст=
	"ВЫБРАТЬ
	|	ХозрасчетныйОстаткиИОбороты.Субконто1 КАК Номенклатура,
	|	ХозрасчетныйОстаткиИОбороты.Субконто2 КАК Склад,
	|	ХозрасчетныйОстаткиИОбороты.СуммаНачальныйОстатокДт + ХозрасчетныйОстаткиИОбороты.СуммаОборотДт КАК Сумма,
	|	ХозрасчетныйОстаткиИОбороты.КоличествоНачальныйОстатокДт + ХозрасчетныйОстаткиИОбороты.КоличествоОборотДт КАК Количество
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.ОстаткиИОбороты(&НачалоПериода, &КонецПериода, , , Счет = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.А2110), , Организация = &Организация) КАК ХозрасчетныйОстаткиИОбороты";
	
	Запрос.УстановитьПараметр("Организация",Организация);
	Запрос.УстановитьПараметр("НачалоПериода",НачалоПериода);
	Запрос.УстановитьПараметр("КонецПериода",КонецПериода);
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции	


	


