export type TRole = {
  id: number;
  type: string;
  roles: TPermissions[];
};

export type TPermissions = {
  id: number;
  adminTypeId: number;
  name: string;
  view: boolean;
  edit: boolean;
  delete: boolean;
};

export type TAdmin = {
  id: number;
  username: string;
  email: string;
  admin_type: { type: string; id: number };
};
