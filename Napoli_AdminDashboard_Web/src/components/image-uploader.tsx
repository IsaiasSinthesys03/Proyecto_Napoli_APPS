import { FileImage, X } from "lucide-react";
import { ChangeEvent, useMemo, useState } from "react";

import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";

interface ImageUploaderProps {
  onFileSelected: (file: File | null) => void;
  initialImageUrl?: string | null;
  disabled?: boolean;
}

export function ImageUploader({
  onFileSelected,
  initialImageUrl,
  disabled = false,
}: ImageUploaderProps) {
  const [preview, setPreview] = useState<string | null>(
    initialImageUrl || null,
  );

  function handleFileSelected(event: ChangeEvent<HTMLInputElement>) {
    const { files } = event.target;

    if (!files || files.length === 0) {
      return;
    }

    const file = files[0];
    onFileSelected(file);

    const previewUrl = URL.createObjectURL(file);
    setPreview(previewUrl);
  }

  function handleRemoveImage() {
    setPreview(null);
    onFileSelected(null);
  }

  const previewContent = useMemo(() => {
    if (preview) {
      return (
        <div className="relative">
          <img
            src={preview}
            alt="Preview"
            className="h-48 w-full rounded-md object-cover"
          />
          <Button
            type="button"
            variant="ghost"
            size="icon"
            onClick={handleRemoveImage}
            className="absolute right-2 top-2 rounded-full bg-black/70 text-white hover:bg-black/80 hover:text-white"
          >
            <X className="h-4 w-4" />
          </Button>
        </div>
      );
    }
    return (
      <div className="flex aspect-video cursor-pointer flex-col items-center justify-center gap-2 rounded-md border border-dashed text-sm text-muted-foreground hover:bg-primary/5">
        <FileImage className="h-4 w-4" />
        <span>Selecione uma imagem</span>
      </div>
    );
  }, [preview]);

  return (
    <div className="space-y-2">
      <Label htmlFor="image">Imagem</Label>
      <label htmlFor="image-upload" className="relative">
        {previewContent}
      </label>
      <input
        type="file"
        id="image-upload"
        className="sr-only"
        accept="image/png, image/jpeg, image/jpg"
        onChange={handleFileSelected}
        disabled={disabled}
      />
    </div>
  );
}
