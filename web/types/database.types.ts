export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      diagnoses: {
        Row: {
          affected_area_pct: number
          confidence: number
          created_at: string
          disease_label: string
          disease_name: string
          id: string
          model_version: string
          severity: Database["public"]["Enums"]["severity_level"]
          upload_id: string
        }
        Insert: {
          affected_area_pct: number
          confidence: number
          created_at?: string
          disease_label: string
          disease_name: string
          id?: string
          model_version?: string
          severity: Database["public"]["Enums"]["severity_level"]
          upload_id: string
        }
        Update: {
          affected_area_pct?: number
          confidence?: number
          created_at?: string
          disease_label?: string
          disease_name?: string
          id?: string
          model_version?: string
          severity?: Database["public"]["Enums"]["severity_level"]
          upload_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "diagnoses_upload_id_fkey"
            columns: ["upload_id"]
            isOneToOne: true
            referencedRelation: "uploads"
            referencedColumns: ["id"]
          },
        ]
      }
      disease_reference: {
        Row: {
          application_schedule: string | null
          crop_type: Database["public"]["Enums"]["crop_type"]
          description: string | null
          disease_label: string
          disease_name: string
          dosage: string | null
          is_verified: boolean
          recommendation_text: string
          updated_at: string
          warning_note: string | null
        }
        Insert: {
          application_schedule?: string | null
          crop_type: Database["public"]["Enums"]["crop_type"]
          description?: string | null
          disease_label: string
          disease_name: string
          dosage?: string | null
          is_verified?: boolean
          recommendation_text: string
          updated_at?: string
          warning_note?: string | null
        }
        Update: {
          application_schedule?: string | null
          crop_type?: Database["public"]["Enums"]["crop_type"]
          description?: string | null
          disease_label?: string
          disease_name?: string
          dosage?: string | null
          is_verified?: boolean
          recommendation_text?: string
          updated_at?: string
          warning_note?: string | null
        }
        Relationships: []
      }
      profiles: {
        Row: {
          created_at: string
          full_name: string
          id: string
          phone: string | null
          role: Database["public"]["Enums"]["user_role"]
        }
        Insert: {
          created_at?: string
          full_name: string
          id: string
          phone?: string | null
          role?: Database["public"]["Enums"]["user_role"]
        }
        Update: {
          created_at?: string
          full_name?: string
          id?: string
          phone?: string | null
          role?: Database["public"]["Enums"]["user_role"]
        }
        Relationships: []
      }
      recommendations: {
        Row: {
          application_schedule: string | null
          created_at: string
          diagnosis_id: string
          dosage: string | null
          id: string
          recommendation_text: string
          warning_note: string | null
        }
        Insert: {
          application_schedule?: string | null
          created_at?: string
          diagnosis_id: string
          dosage?: string | null
          id?: string
          recommendation_text: string
          warning_note?: string | null
        }
        Update: {
          application_schedule?: string | null
          created_at?: string
          diagnosis_id?: string
          dosage?: string | null
          id?: string
          recommendation_text?: string
          warning_note?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "recommendations_diagnosis_id_fkey"
            columns: ["diagnosis_id"]
            isOneToOne: true
            referencedRelation: "diagnoses"
            referencedColumns: ["id"]
          },
        ]
      }
      uploads: {
        Row: {
          captured_at: string
          created_at: string
          id: string
          image_path: string
          uploaded_by: string
          zone_id: string
        }
        Insert: {
          captured_at?: string
          created_at?: string
          id?: string
          image_path: string
          uploaded_by: string
          zone_id: string
        }
        Update: {
          captured_at?: string
          created_at?: string
          id?: string
          image_path?: string
          uploaded_by?: string
          zone_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "uploads_uploaded_by_fkey"
            columns: ["uploaded_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "uploads_zone_id_fkey"
            columns: ["zone_id"]
            isOneToOne: false
            referencedRelation: "zones"
            referencedColumns: ["id"]
          },
        ]
      }
      vegetation_index_readings: {
        Row: {
          created_at: string
          exg_score: number
          health_score: number
          id: string
          upload_id: string
          vari_score: number
        }
        Insert: {
          created_at?: string
          exg_score: number
          health_score: number
          id?: string
          upload_id: string
          vari_score: number
        }
        Update: {
          created_at?: string
          exg_score?: number
          health_score?: number
          id?: string
          upload_id?: string
          vari_score?: number
        }
        Relationships: [
          {
            foreignKeyName: "vegetation_index_readings_upload_id_fkey"
            columns: ["upload_id"]
            isOneToOne: true
            referencedRelation: "uploads"
            referencedColumns: ["id"]
          },
        ]
      }
      zone_health_daily: {
        Row: {
          avg_health_score: number | null
          created_at: string
          date: string
          diagnosis_count: number
          id: string
          status: Database["public"]["Enums"]["zone_status"]
          zone_id: string
        }
        Insert: {
          avg_health_score?: number | null
          created_at?: string
          date: string
          diagnosis_count?: number
          id?: string
          status?: Database["public"]["Enums"]["zone_status"]
          zone_id: string
        }
        Update: {
          avg_health_score?: number | null
          created_at?: string
          date?: string
          diagnosis_count?: number
          id?: string
          status?: Database["public"]["Enums"]["zone_status"]
          zone_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "zone_health_daily_zone_id_fkey"
            columns: ["zone_id"]
            isOneToOne: false
            referencedRelation: "zones"
            referencedColumns: ["id"]
          },
        ]
      }
      zones: {
        Row: {
          created_at: string
          crop_type: Database["public"]["Enums"]["crop_type"]
          id: string
          location_note: string | null
          name: string
          owner_id: string
        }
        Insert: {
          created_at?: string
          crop_type: Database["public"]["Enums"]["crop_type"]
          id?: string
          location_note?: string | null
          name: string
          owner_id: string
        }
        Update: {
          created_at?: string
          crop_type?: Database["public"]["Enums"]["crop_type"]
          id?: string
          location_note?: string | null
          name?: string
          owner_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "zones_owner_id_fkey"
            columns: ["owner_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      current_user_role: {
        Args: never
        Returns: Database["public"]["Enums"]["user_role"]
      }
    }
    Enums: {
      crop_type: "tomat" | "cabai"
      severity_level: "ringan" | "sedang" | "parah"
      user_role: "admin_ppl" | "petani"
      zone_status: "sehat" | "waspada" | "perlu_tindakan"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      crop_type: ["tomat", "cabai"],
      severity_level: ["ringan", "sedang", "parah"],
      user_role: ["admin_ppl", "petani"],
      zone_status: ["sehat", "waspada", "perlu_tindakan"],
    },
  },
} as const
