#pragma once
#include <fstream>
#include <ios>
#include <iostream>
#include <iterator>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

class Table {
private:
  std::vector<std::string> headers_;
  std::vector<std::vector<std::string>> rows_;
  
  std::vector<std::string> split(std::string& line, char delimiter) {
    std::stringstream stream(line);
    std::vector<std::string> result;
    std::string token;
    while (std::getline(stream, token, delimiter)){
        result.push_back(token);
    }
    return result;
  }

  int find_col_index(const std::string& col_name){
    int idx = 0;
    for (const std::string& key : headers_){
        if (col_name == key){
            return idx;
        }
        idx ++;
    }
    throw std::runtime_error("Column not found.");
  }

public:
  void parse(const std::string &file_name) {
    std::ifstream file(file_name);
    if (!file.is_open()){
        throw std::runtime_error("File not found.");
    }
    std::string line;
    std::getline(file, line);
    headers_ = split(line, ',');
    while (std::getline(file, line)) {
        if (line.empty()) {continue;}
        rows_.push_back(split(line, ','));
    }
  }

  void print(){
    std::cout<<"Headers are: ";
    for (const std::string& header: headers_){
        std::cout<<header<<" ,";
    }
    std::cout<<"Rows are: \n";
    for (const std::vector<std::string>& row: rows_){
        for (const std::string& field: row){
            std::cout<<field<<", ";
        }
        std::cout<<"\n";
    }
  }

  Table filter(const std::string& column, const std::string& value) {
    Table result;
    result.headers_ = headers_;
    int idx = find_col_index(column);
    for (const std::vector<std::string>& row: rows_){
        if (row[idx] == value){
            result.rows_.push_back(row);
        }
    }
    return result;
  }

  double sum(const std::string& column){
    double result = 0;
    int idx = find_col_index(column);
    for (const std::vector<std::string>& row: rows_){
        result = result + std::stod(row[idx]);
    }
    return result;
  }
};