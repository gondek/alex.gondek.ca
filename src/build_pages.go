package main

import (
	"html/template"
	"os"
	"path/filepath"
	"runtime"
)

type Page struct {
	BaseTemplate     string
	PageTemplate     string
	CssClass         string
	OutputPath       string
	PageSpecificData interface{}
}

func GetPages() []Page {
	return []Page{
		{
			BaseTemplate: "base",
			PageTemplate: "home",
			CssClass:     "home",
			OutputPath:   "index.html",
		},
	}
}

func BuildPages() error {
	_, scriptFilename, _, _ := runtime.Caller(0)
	repoRoot := filepath.Dir(filepath.Dir(scriptFilename))
	baseTemplatesPath := filepath.Join(repoRoot, "src", "templates", "base", "*.gohtml")

	siteOutputDir := os.Getenv("OUTPUT_DIR")
	if siteOutputDir == "" {
		panic("OUTPUT_DIR env var is not set")
	}
	buildDir := filepath.Join(repoRoot, siteOutputDir)
	baseTemplates := template.Must(template.ParseGlob(baseTemplatesPath))

	for _, page := range GetPages() {
		pageTemplates := template.Must(baseTemplates.Clone())
		pageTemplateFile := filepath.Join(repoRoot, "src", "templates", "pages", page.PageTemplate+".gohtml")
		template.Must(pageTemplates.ParseFiles(pageTemplateFile))

		outputPath := filepath.Join(buildDir, page.OutputPath)
		err := generatePage(outputPath, page, pageTemplates)
		if err != nil {
			return err
		}
	}

	return nil
}

func generatePage(outputPath string, page Page, tmpl *template.Template) error {
	f, err := os.Create(outputPath)
	if err != nil {
		return err
	}

	defer func(f *os.File) {
		_ = f.Close()
	}(f)

	if err := tmpl.ExecuteTemplate(f, page.BaseTemplate, page); err != nil {
		return err
	}

	return nil
}

func main() {
	err := BuildPages()
	if err != nil {
		panic(err)
	}
}
