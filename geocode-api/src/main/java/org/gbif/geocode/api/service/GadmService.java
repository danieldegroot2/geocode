package org.gbif.geocode.api.service;

import org.gbif.api.model.common.paging.Pageable;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.geocode.api.model.GadmRegion;

import java.util.Collection;
import javax.annotation.Nullable;
import javax.validation.constraints.Max;
import javax.validation.constraints.Min;

public interface GadmService {

  Collection<GadmRegion> listLevel0(@Nullable String query);

  Collection<GadmRegion> listLevel1(@Nullable String query, String gid0);

  Collection<GadmRegion> listLevel2(@Nullable String query, String gid0, String gid1);

  Collection<GadmRegion> listLevel3(@Nullable String query, String gid0, String gid1, String gid2);

  PagingResponse<GadmRegion> search(@Nullable String query,
                                    @Max(value = 2, message = "Only levels 0, 1 and 2 are supported")
                                    @Min(value = 0, message = "Only levels 0, 1 and 2 are supported")
                                    @Nullable Integer level,
                                    @Nullable String gid,
                                    @Nullable Pageable page);
}
