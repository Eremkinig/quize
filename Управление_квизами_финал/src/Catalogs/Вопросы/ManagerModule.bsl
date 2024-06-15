#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.ЗагрузкаДанныхИзФайла

// Устанавливает параметры загрузки данных из файла.
//
// Параметры:
//  Параметры - см. ЗагрузкаДанныхИзФайла.ПараметрыЗагрузкиИзФайла
// 
Процедура ОпределитьПараметрыЗагрузкиДанныхИзФайла(Параметры) Экспорт

	Параметры.Заголовок = НСтр("ru = 'Вопросы'");
	Параметры.ПредставлениеОбъекта = НСтр("ru = 'Вопросы'");

	ОписаниеТипаВопрос = Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(500));
	ОписаниеТипаОтвет = Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(50));
	Параметры.ТипДанныхКолонки.Вставить("Вопрос", ОписаниеТипаВопрос);
	Параметры.ТипДанныхКолонки.Вставить("Ответ", ОписаниеТипаОтвет);

КонецПроцедуры

// Производит сопоставление загружаемых данных с данными в ИБ.
// Состав и тип колонок таблицы соответствует реквизитам справочника или макету "ЗагрузкаИзФайла".
//
// Параметры:
//   ЗагружаемыеДанные - см. ЗагрузкаДанныхИзФайла.ТаблицаСопоставления
//
Процедура СопоставитьЗагружаемыеДанныеИзФайла(ЗагружаемыеДанные) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ДанныеДляСопоставления.Вопрос КАК Вопрос,
	|	ДанныеДляСопоставления.Ответ КАК Ответ,
	|	ДанныеДляСопоставления.Идентификатор КАК Идентификатор
	|ПОМЕСТИТЬ ДанныеДляСопоставления
	|ИЗ
	|	&ДанныеДляСопоставления КАК ДанныеДляСопоставления
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ДанныеДляСопоставления.Вопрос,
	|	ДанныеДляСопоставления.Ответ,
	|	ДанныеДляСопоставления.Идентификатор
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Вопросы.Ссылка КАК Ссылка,
	|	Вопросы.Вопрос КАК Вопрос,
	|	ДанныеДляСопоставления.Идентификатор КАК Идентификатор
	|ПОМЕСТИТЬ СопоставленныйВопросы
	|ИЗ
	|	ДанныеДляСопоставления КАК ДанныеДляСопоставления
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Вопросы КАК Вопросы
	|		ПО ((ВЫРАЗИТЬ(Вопросы.Вопрос КАК СТРОКА(1000))) = ДанныеДляСопоставления.Вопрос)
	|			И (Вопросы.ПометкаУдаления = ЛОЖЬ)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДанныеДляСопоставления.Вопрос КАК Вопрос,
	|	ДанныеДляСопоставления.Идентификатор КАК Идентификатор
	|ПОМЕСТИТЬ ДанныеДляСопоставленияПоВопросу
	|ИЗ
	|	ДанныеДляСопоставления КАК ДанныеДляСопоставления
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ СопоставленныйВопросы КАК СопоставленныеВопросы
	|		ПО ((ВЫРАЗИТЬ(ДанныеДляСопоставления.Вопрос КАК СТРОКА(1000))) = (ВЫРАЗИТЬ(СопоставленныеВопросы.Вопрос КАК СТРОКА(1000))))
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Вопросы.Ссылка КАК Вопрос,
	|	ДанныеДляСопоставленияПоВопросу.Идентификатор КАК Идентификатор
	|ИЗ
	|	ДанныеДляСопоставленияПоВопросу КАК ДанныеДляСопоставленияПоВопросу
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Вопросы КАК Вопросы
	|		ПО ((ВЫРАЗИТЬ(Вопросы.Вопрос КАК СТРОКА(1000))) = ДанныеДляСопоставленияПоВопросу.Вопрос)
	|			И (Вопросы.ПометкаУдаления = ЛОЖЬ)";

	Запрос.УстановитьПараметр("ДанныеДляСопоставления", ЗагружаемыеДанные);

	РезультатЗапроса = Запрос.Выполнить().Выбрать();

	Пока РезультатЗапроса.Следующий() Цикл
		Фильтр = Новый Структура("Идентификатор", РезультатЗапроса.Идентификатор);
		Строки = ЗагружаемыеДанные.НайтиСтроки(Фильтр);
		Для Каждого Строка Из Строки Цикл
			Строка.ОбъектСопоставления = РезультатЗапроса.Номенклатура;
		КонецЦикла;
	КонецЦикла;

КонецПроцедуры

// Загрузка данных из файла.
//
// Параметры:
//  ЗагружаемыеДанные - см. ЗагрузкаДанныхИзФайла.ОписаниеЗагружаемыхДанныхДляСправочников
//  ПараметрыЗагрузки - см. ЗагрузкаДанныхИзФайла.НастройкиЗагрузкиДанных
//  Отказ - Булево    - отмена загрузки. Например, если данные некорректные.
//
Процедура ЗагрузитьИзФайла(ЗагружаемыеДанные, ПараметрыЗагрузки, Отказ) Экспорт
	
	Для Каждого СтрокаТаблицы Из ЗагружаемыеДанные Цикл
		ОбъектСопоставленияЗаполнен = ЗначениеЗаполнено(СтрокаТаблицы.ОбъектСопоставления);
		
		Если (ОбъектСопоставленияЗаполнен И ПараметрыЗагрузки.ОбновлятьСуществующие = 0)
			Или (Не ОбъектСопоставленияЗаполнен И ПараметрыЗагрузки.СоздаватьНовые = 0) Тогда
			СтрокаТаблицы.РезультатСопоставленияСтроки = "Пропущен";
			Продолжить;
		КонецЕсли;
		
		НачатьТранзакцию();
		Попытка
			
			Если ОбъектСопоставленияЗаполнен Тогда
				
				Блокировка        = Новый БлокировкаДанных;
				ЭлементБлокировки = Блокировка.Добавить("Справочник.Вопросы");
				ЭлементБлокировки.УстановитьЗначение("Ссылка", СтрокаТаблицы.ОбъектСопоставления);
				Блокировка.Заблокировать();
				
				ЭлементСправочника = СтрокаТаблицы.ОбъектСопоставления.ПолучитьОбъект();
				
				Если ЭлементСправочника = Неопределено Тогда
					ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Вопроса %1 не существует.'"), СтрокаТаблицы.Артикул);
				КонецЕсли;
				СтрокаТаблицы.РезультатСопоставленияСтроки = "Обновлен";
				
			Иначе
				
				ЭлементСправочника                         = СоздатьЭлемент();
				СтрокаТаблицы.РезультатСопоставленияСтроки = "Создан";
				
			КонецЕсли;
			
			ЭлементСправочника.Вопрос = СтрокаТаблицы.Вопрос;
			
			ФорматыОтвета = УправлениеКвизамиПовтИсп.ДоступныеФорматыОтвета();
			УдалосьВыполнитьПривидениеКТипу = Ложь;
			Для Каждого ТипДляПривидения Из ФорматыОтвета Цикл
				
				Если УдалосьВыполнитьПривидениеКТипу Тогда
					Прервать;
				КонецЕсли;
				
				Если ТипДляПривидения = Тип("Строка") Тогда
					Продолжить;
				КонецЕсли;
				
				НовоеОписаниеТипа = Новый ОписаниеТипов(ОбщегоНазначения.СтроковоеПредставлениеТипа(ТипДляПривидения));
				Ответ = НовоеОписаниеТипа.ПривестиЗначение(СтрокаТаблицы.Ответ);
				Если ЗначениеЗаполнено(Ответ) Тогда
					УдалосьВыполнитьПривидениеКТипу = Истина;
				КонецЕсли;
				
			КонецЦикла;
			
			Если НЕ УдалосьВыполнитьПривидениеКТипу Тогда
				Ответ = СтрокаТаблицы.Ответ;
			КонецЕсли;
			
			ЭлементСправочника.Ответ = Ответ;
			
			Если ЗначениеЗаполнено(СтрокаТаблицы.Родитель) Тогда
				Родитель = НайтиПоНаименованию(СтрокаТаблицы.Родитель, Истина);
				Если Родитель = Неопределено Или Не Родитель.ЭтоГруппа Или Родитель.Пустая() Тогда
					Родитель = СоздатьГруппу();
					Родитель.Наименование = СтрокаТаблицы.Родитель;
					Родитель.Записать();
				КонецЕсли;
				ЭлементСправочника.Родитель = Родитель.Ссылка;
			КонецЕсли;
			
			КоличествоБаллов = СтроковыеФункцииКлиентСервер.СтрокаВЧисло(СтрокаТаблицы.КоличествоБаллов);
			ЭлементСправочника.КоличествоБаллов = КоличествоБаллов;
			
			Если Не ЭлементСправочника.ПроверитьЗаполнение() Тогда
				СтрокаТаблицы.РезультатСопоставленияСтроки = "Пропущен";
				СообщенияПользователю = ПолучитьСообщенияПользователю(Истина);
				Если СообщенияПользователю.Количество() > 0 Тогда
					ТекстСообщений = "";
					Для Каждого СообщениеПользователю Из СообщенияПользователю Цикл
						ТекстСообщений  = ТекстСообщений + СообщениеПользователю.Текст + Символы.ПС;
					КонецЦикла;
					СтрокаТаблицы.ОписаниеОшибки = ТекстСообщений;
				КонецЕсли;
				ОтменитьТранзакцию();
			Иначе
				ЭлементСправочника.Записать();
				СтрокаТаблицы.ОбъектСопоставления = ЭлементСправочника.Ссылка;
				
				ЗагрузкаДанныхИзФайла.ЗаписатьСвойстваОбъекта(ЭлементСправочника.Ссылка, СтрокаТаблицы);
				
				ЗафиксироватьТранзакцию();
			КонецЕсли;
		Исключение
			ОтменитьТранзакцию();
			Причина = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
			СтрокаТаблицы.РезультатСопоставленияСтроки = "Пропущен";
			СтрокаТаблицы.ОписаниеОшибки = НСтр("ru = 'Невозможна запись данных по причине:'") + Символы.ПС + Причина;
		КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.ЗагрузкаДанныхИзФайла

#КонецОбласти

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция ЭталонныйОтвет(Вопрос) Экспорт
	
Возврат ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Вопрос, "Ответ");
	
КонецФункции

#КонецОбласти

#КонецЕсли
