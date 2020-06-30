package org.gbif.geocode.ws.layers;

import com.google.inject.Singleton;
import org.gbif.geocode.ws.service.impl.MyBatisGeocoder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Singleton
public class SeaVoXLayer extends AbstractBitmapCachedLayer {
  public static Logger LOG = LoggerFactory.getLogger(MyBatisGeocoder.class);

  public SeaVoXLayer() {
    super(SeaVoXLayer.class.getResourceAsStream("seavox.png"));
  }

  @Override
  public String name() {
    return "SeaVoX";
  }
}
