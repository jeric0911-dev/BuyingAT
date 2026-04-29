import { useState } from "react";
import { GridPaginationModel } from "@mui/x-data-grid";

interface ServerPaginationProps {
  defaultPageSize?: number;
}

interface ServerPaginationResult {
  paginationModel: GridPaginationModel;
  handlePaginationModelChange: (model: GridPaginationModel) => void;
  queryParams: { page: number; limit: number };
}

export const useServerPagination = ({
  defaultPageSize = 10,
}: ServerPaginationProps = {}): ServerPaginationResult => {
  const [paginationModel, setPaginationModel] = useState<GridPaginationModel>({
    page: 0,
    pageSize: defaultPageSize,
  });

  const handlePaginationModelChange = (model: GridPaginationModel) => {
    if (model.pageSize !== paginationModel.pageSize) {
      setPaginationModel({ page: 0, pageSize: model.pageSize });
    } else {
      setPaginationModel(model);
    }
  };

  const queryParams = {
    page: paginationModel.page + 1,
    limit: paginationModel.pageSize,
  };

  return {
    paginationModel,
    handlePaginationModelChange,
    queryParams,
  };
};
