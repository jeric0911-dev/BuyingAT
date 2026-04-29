import { PayloadAction, createSlice } from "@reduxjs/toolkit";
import { RootState } from "../../store";
import { TPermissions } from "../../../types";

export type TAuth = {
  user: {
    id: number;
    username: string;
    email: string;
    admin_type: { id: number; type: string, role_parameters: TPermissions[] };
  } | null;
  token: string | null;
};

const initialState: TAuth = {
  user: null,
  token: null,
};

const authSlice = createSlice({
  name: "auth",
  initialState,
  reducers: {
    login: (state, { payload }: PayloadAction<TAuth>) => {
      const { user, token } = payload;
      state.user = user;
      state.token = token;
    },
    logout: (state) => {
      state.user = null;
      state.token = null;
    },
  },
});

export const { login, logout } = authSlice.actions;
export default authSlice.reducer;

export const selectCurrentToken = (state: RootState) => state.auth.token;
export const selectCurrentUser = (state: RootState) => state.auth.user;
