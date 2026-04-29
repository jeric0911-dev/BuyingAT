import { BaseQueryApi } from "@reduxjs/toolkit/query";

export type TMeta = {
  current_page: number;
  per_page: number;
  total: number;
  last_page: number;
};

export type TResponse<T> = {
  data: T;
  error?: any;
  pagination?: TMeta;
  status: "success" | "error";
  message: string;
};

export type TResponseRedux<T> = TResponse<T> & BaseQueryApi;

export type TModalState<T> = {
  type: "view" | "add" | "edit" | "delete" | null;
  data?: T;
};

export type TAddModal = {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
};

export type TUpdateModal<T> = TAddModal & {
  data: T;
};
