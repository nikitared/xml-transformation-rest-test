package ru.babaninnv.edisoft.test.repositories;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;

import java.util.List;
import java.util.Optional;

import ru.babaninnv.edisoft.test.domain.XmlFile;

/**
 * Репозиторий для хранения объектов XmlFile
 *
 * @author Nikita Babanin
 * @version 1.0
 */
public interface XmlFileRepository extends Repository<XmlFile, Long> {

    /**
     * Возвращает список всех записей XmlFile
     */
    @Query("SELECT new ru.babaninnv.edisoft.test.domain.XmlFile(d.id, d.originalName, d.receiveDate) FROM XmlFile d")
    List<XmlFile> findAll();

    /**
     * Возвращает объект XmlFile, который содержит оригинальное наименоваение файла и xml после преобразования
     *
     * @param id идентификатор XML-файла
     */
    @Query("SELECT new ru.babaninnv.edisoft.test.domain.XmlFile(d.originalName, d.transformedFile) FROM XmlFile d WHERE id = ?1")
    Optional<XmlFile> findAttachment(Long id);

    /**
     * Сохраняет в базе данных запись о xml-файле
     *
     * @param xmlFile объект xmlFile
     */
    XmlFile save(XmlFile xmlFile);
}
