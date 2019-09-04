package ru.babaninnv.edisoft.test.routes;

import org.apache.camel.CamelContext;
import org.apache.camel.Exchange;
import org.apache.camel.ProducerTemplate;
import org.apache.camel.builder.NotifyBuilder;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.properties.PropertiesComponent;
import org.apache.camel.converter.IOConverter;
import org.apache.camel.spring.javaconfig.SingleRouteCamelConfiguration;
import org.apache.camel.test.spring.CamelSpringRunner;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ContextConfiguration;
import ru.babaninnv.edisoft.test.routes.processors.ExceptionHandlerProcessor;
import ru.babaninnv.edisoft.test.routes.processors.XmlFilePersistProcessor;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;

/**
 * @author Nikita Babanin
 * @version 1.0
 */
@RunWith(CamelSpringRunner.class)
@ContextConfiguration(classes = XsltRouterTest.TestConfiguration.class)
public class XsltRouterTest {

    @Autowired
    private CamelContext context;

    @Autowired
    private ProducerTemplate template;

    @Autowired
    private XmlFilePersistProcessor xmlFilePersistProcessor;

    @Autowired
    private ExceptionHandlerProcessor exceptionHandlerProcessor;

    @DirtiesContext
    @Test
    public void route() throws Exception {
        // создать билдер, который позволит дождаться прохождения роута
        NotifyBuilder notify = new NotifyBuilder(context).whenDone(1).create();

        template.sendBodyAndHeader("file:{{client.input.folder}}",
                IOConverter.toFile("src/test/resources/test_order.xml"), "CamelFileName", "test_order.xml");

        assertTrue(notify.matchesMockWaitTime());

        // проверка, что процессор был вызван
        ArgumentCaptor<Exchange> exchangeCaptor = ArgumentCaptor.forClass(Exchange.class);
        verify(xmlFilePersistProcessor).process(exchangeCaptor.capture());

        // Проверка, что входные параметры для процессора коррктны
        Exchange exchange = exchangeCaptor.getValue();
        assertEquals("test_order.xml", exchange.getIn().getExchange().getProperty("originalFileName"));
        assertNotNull(exchange.getIn().getExchange().getProperty("originalBody"));
        assertNotNull(exchange.getIn().getBody());

        // процессор обработчика исключения вызываться не должен
        verify(exceptionHandlerProcessor, never()).process(any(Exchange.class));
    }

    @DirtiesContext
    @Test
    public void route_When_xmlHasError() throws Exception {
        // создать билдер, который позволит дождаться прохождения роута
        NotifyBuilder notify = new NotifyBuilder(context).whenDone(1).create();

        template.sendBodyAndHeader("file:{{client.input.folder}}",
                IOConverter.toFile("src/test/resources/test_order_with_error.xml"), "CamelFileName",
                "test_order_with_error.xml");

        assertTrue(notify.matchesMockWaitTime());

        // проверка, что процессор обработчика исключения был вызван
        verify(exceptionHandlerProcessor).process(any(Exchange.class));

        // процессор сохранения вызываться не должен
        verify(xmlFilePersistProcessor, never()).process(any(Exchange.class));
    }

    @Configuration
    public static class TestConfiguration extends SingleRouteCamelConfiguration {
        @Override
        public RouteBuilder route() {
            return new XsltRouter(xmlFilePersistProcessor(), exceptionHandlerProcessor());
        }

        @Override
        protected void setupCamelContext(CamelContext camelContext) throws Exception {
            PropertiesComponent propertiesComponent = new PropertiesComponent();
            propertiesComponent.setLocation("classpath:xslt_router_test.properties");
            camelContext.addComponent("properties", propertiesComponent);
        }

        @Bean
        public XmlFilePersistProcessor xmlFilePersistProcessor() {
            return mock(XmlFilePersistProcessor.class);
        }

        @Bean
        public ExceptionHandlerProcessor exceptionHandlerProcessor() {
            return mock(ExceptionHandlerProcessor.class);
        }
    }
}