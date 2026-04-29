import {
  Box,
  Typography,
  Stack,
  Avatar,
  Chip,
  Divider,
  Grid,
  Menu,
  MenuItem,
} from "@mui/material";
import StarIcon from "@mui/icons-material/Star";
import ImageSlider from "./ImageSlider";
import ColorBox from "./ColorBox";
import SizeBox from "./SizeBox";
import VariantBox from "./VariantBox";
import ProductDetailTab from "./ProductDetailTab";
import RCModal from "../../modal/RCModal";
import { TProduct, TUpdateModal } from "../../../types";
import { useUpdateProductMutation } from "../../../redux/features/productManagement/productManagementApi";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { useState } from "react";
import { ArrowDropDownIcon } from "@mui/x-date-pickers";

const ProductDetailsModal = ({
  open,
  setOpen,
  data,
}: TUpdateModal<TProduct>) => {
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [updateStatus] = useUpdateProductMutation();

  const handleStatusUpdate = async (status: TProduct["status"]) => {
    handleAsyncToast({
      promise: updateStatus({ product_id: data.id, status }).unwrap(),
      success: () => {
        setOpen(false);
        return "Status updated successfully!";
      },
    });
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Product Details">
      <Box>
        <ImageSlider slides={data?.get_gallery_images} />
        <Stack
          direction="row"
          alignItems="center"
          justifyContent="space-between"
          mt={2}
        >
          <Chip
            label={data?.status}
            onClick={(e) => setAnchorEl(e.currentTarget)}
            color={
              data?.status === "Active"
                ? "success"
                : data?.status === "Pending"
                ? "warning"
                : data?.status === "Rejected"
                ? "error"
                : data?.status === "Unpublished"
                ? "info"
                : data?.status === "Disabled"
                ? "secondary"
                : "default"
            }
            variant="outlined"
            deleteIcon={<ArrowDropDownIcon />}
            onDelete={(e) => setAnchorEl(e.currentTarget)}
            sx={{ cursor: "pointer" }}
          />
          <Menu
            anchorEl={anchorEl}
            open={Boolean(anchorEl)}
            onClose={() => setAnchorEl(null)}
          >
            {["Active", "Rejected", "Disabled"].map((status) => (
              <MenuItem
                key={status}
                onClick={() => {
                  handleStatusUpdate(status as TProduct["status"]);
                  setAnchorEl(null);
                }}
                selected={data?.status === status}
              >
                {status}
              </MenuItem>
            ))}
          </Menu>
          {data?.is_featured === 1 && (
            <Chip
              label="Featured"
              color="primary"
              icon={<StarIcon fontSize="small" />}
            />
          )}
        </Stack>
        <Typography variant="h5" fontWeight={600} mt={2}>
          {data?.product_title}
        </Typography>
        <Grid container spacing={2} mt={1}>
          <Grid item xs={12} sm={6}>
            <Typography variant="body2" color="text.secondary">
              SKU: <strong>{data?.sku}</strong>
            </Typography>
            <Typography variant="body2" color="text.secondary" mt={0.5}>
              Brand: <strong>{data?.get_brand?.brand_name}</strong>
            </Typography>
            <Typography variant="body2" color="text.secondary" mt={0.5}>
              Category: <strong>{data?.get_category?.category_name}</strong>
            </Typography>
            <Typography variant="body2" color="text.secondary" mt={0.5}>
              Subcategory:{" "}
              <strong>{data?.get_sub_category?.sub_category_name}</strong>
            </Typography>
          </Grid>
          <Grid item xs={12} sm={6}>
            <Stack direction="row" spacing={2} alignItems="center">
              <Avatar
                src={`${import.meta.env.VITE_IMG_URL}/${
                  data?.get_product_user?.profile_img
                }`}
              />
              <Box>
                <Typography variant="body2" fontWeight={600}>
                  {data?.get_product_user?.name}
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  User ID: {data?.get_product_user?.id}
                </Typography>
              </Box>
            </Stack>
          </Grid>
        </Grid>
        <Stack direction="row" alignItems="center" spacing={2} mt={3}>
          <Typography variant="h6" fontWeight={700} color="primary">
            ${data?.discounted_price || data?.price}
          </Typography>
          {data?.discounted_price && (
            <Typography
              variant="body2"
              color="text.secondary"
              sx={{ textDecoration: "line-through" }}
            >
              ${data?.price}
            </Typography>
          )}
        </Stack>
        <Divider sx={{ my: 3 }} />
        <Stack spacing={3}>
          {data?.colors?.length > 0 && <ColorBox colors={data.colors} />}
          {data?.sizes?.length > 0 && <SizeBox sizes={data.sizes} />}
          {data?.variants?.length > 0 && (
            <VariantBox variants={data.variants} />
          )}
        </Stack>
        <Divider sx={{ my: 4 }} />
        <Box mt={4}>
          <ProductDetailTab data={data} />
        </Box>
      </Box>
    </RCModal>
  );
};

export default ProductDetailsModal;
