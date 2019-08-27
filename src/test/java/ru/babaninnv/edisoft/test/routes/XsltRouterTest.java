package ru.babaninnv.edisoft.test.routes;

import org.apache.camel.component.jpa.JpaEndpoint;
import org.apache.camel.component.properties.PropertiesComponent;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.impl.PropertyPlaceholderDelegateRegistry;
import org.apache.camel.impl.SimpleRegistry;
import org.apache.camel.spi.Registry;
import org.junit.Test;

import java.util.concurrent.TimeUnit;

import javax.persistence.EntityManagerFactory;

import ru.babaninnv.edisoft.test.domain.XmlFile;
import ru.babaninnv.edisoft.test.service.XmlFileService;

import static org.mockito.Mockito.mock;

/**
 * @author Nikita Babanin
 * @version 1.0
 */
public class XsltRouterTest {
    @Test
    public void route() throws Exception {
        DefaultCamelContext camelContext  = new DefaultCamelContext();

        XmlFileService xmlFileService = mock(XmlFileService.class);

        SimpleRegistry simpleRegistry = new SimpleRegistry();
        simpleRegistry.put("xmlFileService", xmlFileService);
        Registry registry = new PropertyPlaceholderDelegateRegistry(camelContext, simpleRegistry);
        camelContext.setRegistry(registry);

        PropertiesComponent propertiesComponent = new PropertiesComponent();
        propertiesComponent.setLocation("classpath:xslt_router_test.properties");
        camelContext.addComponent("properties", propertiesComponent);

        camelContext.addRoutes(new XsltRouter());

        JpaEndpoint jpaEndpoint = camelContext.getEndpoint("jpa://" + XmlFile.class.getName(), JpaEndpoint.class);
        EntityManagerFactory entityManagerFactoryMock = mock(EntityManagerFactory.class);
        jpaEndpoint.setEntityManagerFactory(entityManagerFactoryMock);

        camelContext.start();

        TimeUnit.SECONDS.sleep(2);
        camelContext.stop();

        //verify(entityManagerFactoryMock).createEntityManager();
        //verify(xmlFileService).generateXmlFile(anyString(), any(byte[].class), any(byte[].class));
    }
}