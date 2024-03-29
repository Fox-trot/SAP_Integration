﻿
////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЙ ПРОГРАММНЫЙ ИНТЕРФЕЙС

// Извлечь текст из файла и возвратить его в виде строки.
Функция ИзвлечьТекст(ПолноеИмяФайла, Отказ = Ложь, Кодировка = Неопределено) Экспорт
	
	ИзвлеченныйТекст = "";
	
	// Обработчик удален из-за отсутствия необходимости
	
	Возврат ИзвлеченныйТекст;
	
КонецФункции

// Извлечь текст из файла и поместить во временное хранилище.
Функция ИзвлечьТекстВоВременноеХранилище(ПолноеИмяФайла, УникальныйИдентификатор = "", Отказ = Ложь,
	Кодировка = Неопределено) Экспорт
	
	АдресВременногоХранилища = "";
	
#Если Не ВебКлиент Тогда
	
	Текст = ИзвлечьТекст(ПолноеИмяФайла, Отказ, Кодировка);
	
	Если ПустаяСтрока(Текст) Тогда
		Возврат "";
	КонецЕсли;
		
#Если Клиент Тогда
	АдресВременногоХранилища = ПоместитьВоВременноеХранилище(Текст, УникальныйИдентификатор);
#Иначе
	Возврат Текст;
#КонецЕсли
	
#КонецЕсли
	
	Возврат АдресВременногоХранилища;
	
КонецФункции

// Получить уникальное имя файла в рабочем каталоге.
//  Если есть совпадения - будет имя подобное "A1\Приказ.doc".
//
Функция ПолучитьУникальноеИмяСПутем(ИмяКаталога, ИмяФайла, ТипПлатформыТекущий) Экспорт
	
	ИтоговыйПуть = "";
	
	Счетчик = 0;
	ЦиклНомер = 0;
	Успешно = Ложь;
	
	ГенераторСлучая = Неопределено;
	
#Если Не ВебКлиент Тогда
	// ТекущаяДата() используется только для генерации случайного числа,
	// поэтому приведение к ТекущаяДатаСеанса не требуется.
	ГенераторСлучая = Новый ГенераторСлучайныхЧисел(Секунда(ТекущаяДата()));
#КонецЕсли
	
	Пока НЕ Успешно И ЦиклНомер < 100 Цикл
		НомерКаталога = 0;
#Если Не ВебКлиент Тогда
		НомерКаталога = ГенераторСлучая.СлучайноеЧисло(0, 25);
#Иначе
		// ТекущаяДата() используется только для генерации случайного числа,
		// поэтому приведение к ТекущаяДатаСеанса не требуется.
		НомерКаталога = Секунда(ТекущаяДата()) % 26;
#КонецЕсли
		
		КодБукваA = КодСимвола("A", 1); 
		КодКаталога = КодБукваA + НомерКаталога;
		
		БукваКаталога = Символ(КодКаталога);
		
		ПодКаталог = ""; // Частичный путь.
		
		// По умолчанию вначале используется корень, если возможности нет,
		// то добавляется A, B, ... Z,  A1, B1, .. Z1, ..  A2, B2 и т.д.
		Если  Счетчик = 0 Тогда
			ПодКаталог = "";
		Иначе
			ПодКаталог = БукваКаталога; 
			ЦиклНомер = Окр(Счетчик / 26);
			
			Если ЦиклНомер <> 0 Тогда
				ЦиклНомерСтрока = Строка(ЦиклНомер);
				ПодКаталог = ПодКаталог + ЦиклНомерСтрока;
			КонецЕсли;
			
			ПодКаталог = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(
				ПодКаталог, ТипПлатформыТекущий);
		КонецЕсли;
		
		ПолныйПодКаталог = ИмяКаталога + ПодКаталог;
		
		// Создание каталога для файлов.
		КаталогНаДиске = Новый Файл(ПолныйПодКаталог);
		Если НЕ КаталогНаДиске.Существует() Тогда
			Попытка
				СоздатьКаталог(ПолныйПодКаталог);
			Исключение
				ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Ошибка при создании каталога ""%1"":
					           |""%2"".'"),
					ПолныйПодКаталог,
					КраткоеПредставлениеОшибки(ИнформацияОбОшибке()) );
			КонецПопытки;
		КонецЕсли;
		
		ФайлПопытки = ПолныйПодКаталог + ИмяФайла;
		Счетчик = Счетчик + 1;
		
		// Проверка, есть ли файл с таким именем.
		ФайлНаДиске = Новый Файл(ФайлПопытки);
		Если НЕ ФайлНаДиске.Существует() Тогда  // Нет такого файла.
			ИтоговыйПуть = ПодКаталог + ИмяФайла;
			Успешно = Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат ИтоговыйПуть;
	
КонецФункции

// Возвращает стандартный текст ошибки.
Функция ОшибкаФайлНеНайденВХранилищеФайлов(ИмяФайла, ПоискВТоме = Истина) Экспорт
	
	Если ПоискВТоме Тогда
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Ошибка открытия файла:
			           |""%1"".
			           |
			           |Файл не найден в хранилище файлов.
			           |Возможно файл удален антивирусной программой.
			           |Обратитесь к администратору.'"),
			ИмяФайла);
	Иначе
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Ошибка открытия файла:
			           |""%1"".
			           |
			           |Файл не найден в хранилище файлов.
			           |Обратитесь к администратору.'"),
			ИмяФайла);
	КонецЕсли;
	
	Возврат ТекстОшибки;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Для пользовательского интерфейса

// Возвращает Строку сообщения о недопустимости подписания занятого файла
//
Функция СтрокаСообщенияОНедопустимостиПодписанияЗанятогоФайла(ФайлСсылка = Неопределено) Экспорт
	
	Если ФайлСсылка = Неопределено Тогда
		Возврат НСтр("ru = 'Нельзя подписать занятый файл.'");
	Иначе
		Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Нельзя подписать занятый файл: %1.'"),
			Строка(ФайлСсылка) );
	КонецЕсли;
	
КонецФункции

// Возвращает Строку сообщения о недопустимости подписания зашифрованного файла
//
Функция СтрокаСообщенияОНедопустимостиПодписанияЗашифрованногоФайла(ФайлСсылка = Неопределено) Экспорт
	
	Если ФайлСсылка = Неопределено Тогда
		Возврат НСтр("ru = 'Нельзя подписать зашифрованный файл.'");
	Иначе
		Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Нельзя подписать зашифрованный файл: %1.'"),
						Строка(ФайлСсылка) );
	КонецЕсли;
	
КонецФункции
